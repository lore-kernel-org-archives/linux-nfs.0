From: Ralph Churchill <mrchucho@yahoo.com>
Subject: Re: (no subject)
Date: Thu, 16 Oct 2003 12:42:30 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20031016194230.45221.qmail@web11402.mail.yahoo.com>
References: <20031014195023.43314.qmail@web11410.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AAE4G-0003Hh-00
	for <nfs@lists.sourceforge.net>; Thu, 16 Oct 2003 12:45:53 -0700
Received: from web11402.mail.yahoo.com ([216.136.131.232])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1AAE3y-0004xw-SJ
	for nfs@lists.sourceforge.net; Thu, 16 Oct 2003 12:45:34 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20031014195023.43314.qmail@web11410.mail.yahoo.com>
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

--- Ralph Churchill <mrchucho@yahoo.com> wrote:
> I am experiencing a strange problem wherein a file
> placed on an exported directory accessible by
> multiple
> clients is occassionally only visible to SOME
> clients.
> However, if I "force" some fake activity on the
> shared
> directory (e.g. touching, then deleting a file in an
> infinite loop), then ALL clients see the file at ALL
> times. This leads me to belive the problem is
> related
> to some buffering or caching... but where?
> 
> Relevant information:
> 
> Clients
> -------
> RedHat 9
> kernel 2.6.0-test7
> mounted
> 'rsize=8192,wsize=8192,noatime,nodiratime,noac'
> 
> Server
> ------
> RedHat 9
> kernel 2.4.20-8
> nfs-utils-1.0.1-2.9
> exported "*(rw)"
> dir is 'ext3' mounted with 'noatime, nodiratime'

I have a feeling that this inconsistent behavior may
be due to the way our application, matlab, is opening
and closing files. The fact that generating nfs
activity, in the form of a trival read and write in
the shell, causes the problem to disappear leads me to
this conclusion. It seems like it may be buffer
related. Is there anyway I can verify this?

Also, I've tried the 'noac' and 'nocto' options, and
while the 'noac' option seems to decrease response
times, the problems persist. Thank you.

RMC 

__________________________________
Do you Yahoo!?
The New Yahoo! Shopping - with improved product search
http://shopping.yahoo.com


-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
