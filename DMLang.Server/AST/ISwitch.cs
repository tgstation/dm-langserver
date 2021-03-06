﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DMLang.Server.AST
{
	interface ISwitch : IStatement
	{
		IExpression Condition { get; }
		IBlock Default { get; }
		IDictionary<IConstantValue, IBlock> Cases { get; }
	}
}
