From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Non-blocking lock requests during the grace period
Date: Fri, 15 Nov 2002 21:01:21 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <15829.21137.152716.652146@helicity.uio.no>
References: <OF5A692563.A6ED6EBB-ON87256C72.0068B38D@us.ibm.com>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Juan Gomez <juang@us.ibm.com>
In-Reply-To: <OF5A692563.A6ED6EBB-ON87256C72.0068B38D@us.ibm.com>
List-ID: <nfs.lists.sourceforge.net>

>>>>> " " == Juan Gomez <juang@us.ibm.com> writes:

     > (note that F_GETLK man page does not provide EAGAIN as a
     > possible error code).

Hmm....

In the Single UNIX spec, there appears to be a rather unexpected
difference between expected behaviour for lockf and fcntl here:


http://www.db.opengroup.org/cgi-bin/dbcgi?CALLER=sud2/indx.tpl&TOKEN=FIYR&TPL=sd_fileframe&dir=xsh&file=lockf

[EACCES] or [EAGAIN]
       The function argument is F_TLOCK or F_TEST and the section is already
       locked by another process.

OTOH

http://www.db.opengroup.org/cgi-bin/dbcgi?CALLER=sud2/indx.tpl&TOKEN=FIYR&TPL=sd_fileframe&dir=xsh&file=fcntl

[EACCES] or [EAGAIN]
    The cmd argument is F_SETLK, and one of the following conditions
    is true:

        * The type of lock (l_type) is shared ( F_RDLCK) or exclusive
          ( F_WRLCK), and the segment of a file to be locked is
          already exclusive locked by another process.
        * The type of lock is exclusive, and some portion of the file
          segment to be locked is already shared locked or exclusive
          locked by another process.

Cheers,
  Trond
