From: Dan Brunner <daniel.brunner@duni.com>
Subject: Re: nfs over tcp in linux kernel version 2.4.18
Date: Tue, 20 May 2003 14:02:38 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <A022BF74-8AF5-11D7-93AF-00306589E6DA@duni.com>
References: <20030520180237.13669.qmail@web21005.mail.yahoo.com>
Mime-Version: 1.0 (Apple Message framework v552)
Content-Type: text/plain; charset=US-ASCII; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [65.168.147.194] (helo=mkeweb01.duni.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19ICNr-0003XJ-00
	for <nfs@lists.sourceforge.net>; Tue, 20 May 2003 12:02:47 -0700
Received: from duni.com ([163.165.101.11])
	by mkeweb01.duni.com (8.11.6/linuxconf) with ESMTP id h4KJ3lu10992
	for <nfs@lists.sourceforge.net>; Tue, 20 May 2003 14:03:47 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <20030520180237.13669.qmail@web21005.mail.yahoo.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello!!

You need to patch  2.4.18 to be able to use NFS over TCP.

And recompile the kernel.


http://www.fys.uio.no/%7Etrondmy/src/2.4.18/

for the patches.


It works quite well....



I believe the client already has it. Just use -t for a TCP mount.


Dan




On Tuesday, May 20, 2003, at 01:02  PM, davidmyer800@yahoo.com wrote:

> Hi,
>
> Can anyone advise me if nfs server over tcp is
> supported in 2.4.18 kernel version ? How to
> setup/enable on both server/client side ? Tried to
> looked at FAQ but information did not seem be there.
>
> Do I need to apply any patches ?
>
> Thanks
> David
>
> __________________________________
> Do you Yahoo!?
> The New Yahoo! Search - Faster. Easier. Bingo.
> http://search.yahoo.com
>
>
> -------------------------------------------------------
> This SF.net email is sponsored by: ObjectStore.
> If flattening out C++ or Java code to make your application fit in a
> relational database is painful, don't do it! Check out ObjectStore.
> Now part of Progress Software. http://www.objectstore.net/sourceforge
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
