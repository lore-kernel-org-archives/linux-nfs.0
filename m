From: Kenny Simpson <theonetruekenny@yahoo.com>
Subject: Re: [NFS client] NFS locks not released on abnormal process termination
Date: Tue, 9 Dec 2003 18:42:58 -0800 (PST)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <20031210024258.26284.qmail@web20022.mail.yahoo.com>
References: <8765gpvnfv.fsf@ceramic.fifi.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Philippe Troin <phil@fifi.org>, trond.myklebust@fys.uio.no
In-Reply-To: <8765gpvnfv.fsf@ceramic.fifi.org>
List-ID: <nfs.lists.sourceforge.net>

> I've ran test overnight on four boxen, and no locks were lost.
> I guess you can send this patch to Marcello now.
>
Excellent work!

> > There are still 2 other issues with the generic POSIX locking code.
> > Both issues have to do with CLONE_VM and have been raised on
> > linux-kernel & linux-fsdevel. Unfortunately they met with no response,
> > so I'm unable to pursue...
> 
> Can we help? Pointers?
Let me know if/how I can help.

Again, great work.

thanks,
-Kenny

__________________________________
Do you Yahoo!?
Free Pop-Up Blocker - Get it now
http://companion.yahoo.com/
