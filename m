From: =?iso-8859-1?Q?J=F6rn?= Engel <joern@wohnheim.fh-wedel.de>
Subject: include/linux/nfs/nfsfh.h declares a symbol
Date: Wed, 1 Oct 2003 14:18:11 +0200
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20031001121811.GE31698@wohnheim.fh-wedel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Neil Brown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
List-ID: <nfs.lists.sourceforge.net>

Neil, the function SVCFH_fmt uses a static variable to sprintf into.
Looks like this variable is declared locally for every .c file
including nfsfh.h, which is quite a few.

You could remove the static, but that would increase the stack usage,
which might be a problem too.  The buffer could be reduced to 64
chars, to reduce that problem.  kmalloc()ing it seems a bit expensive,
but might be an option, too.

Thanks!

J=F6rn

--=20
This above all: to thine own self be true.
-- Shakespeare
