From: Ralph Churchill <mrchucho@yahoo.com>
Subject: Re: inconsistent NFS clients(was 'no subject')
Date: Mon, 20 Oct 2003 12:27:01 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20031020192701.25085.qmail@web11405.mail.yahoo.com>
References: <20031016194230.45221.qmail@web11402.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1ABh9n-0005KD-00
	for <nfs@lists.sourceforge.net>; Mon, 20 Oct 2003 14:01:39 -0700
Received: from web11405.mail.yahoo.com ([216.136.131.235])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.22)
	id 1ABfj8-0002Ls-9J
	for nfs@lists.sourceforge.net; Mon, 20 Oct 2003 12:30:02 -0700
To: nfs@lists.sourceforge.net
In-Reply-To: <20031016194230.45221.qmail@web11402.mail.yahoo.com>
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

I am still trying to track down this problem. I
upgraded to kernel 2.6-test8, but the problems
persist. Our application works by clients polling a
shared directory and touching files to indicate status
(beginning, done, etc.). Let's say client A touchs a
file, "begin", in the shared dir. If I write a shell
script to repeatedly do an 'ls /share', client B will
show the "begin" file. However, client A will say:

ls: /shared/begin: No such file or directory

This is confusing, because I'm NOT doing 'ls
/share/begin'!! It strikes me as odd that this file
isn't showing up to being with(when it clearly IS
there on the server and other clients), but also 'ls'
"thinks" it is there, but can't find it??

Again, I could REALLY use some help, this is very
confusing. I've tried just about EVERY combination of
options! Thanks.

RMC


--- Ralph Churchill <mrchucho@yahoo.com> wrote:
> --- Ralph Churchill <mrchucho@yahoo.com> wrote:
> > I am experiencing a strange problem wherein a file
> > placed on an exported directory accessible by
> > multiple
> > clients is occassionally only visible to SOME
> > clients.
> > However, if I "force" some fake activity on the
> > shared
> > directory (e.g. touching, then deleting a file in
> an
> > infinite loop), then ALL clients see the file at
> ALL
> > times. This leads me to belive the problem is
> > related
> > to some buffering or caching... but where?
> > 
> > Relevant information:
> > 
> > Clients
> > -------
> > RedHat 9
> > kernel 2.6.0-test7
> > mounted
> > 'rsize=8192,wsize=8192,noatime,nodiratime,noac'
> > 
> > Server
> > ------
> > RedHat 9
> > kernel 2.4.20-8
> > nfs-utils-1.0.1-2.9
> > exported "*(rw)"
> > dir is 'ext3' mounted with 'noatime, nodiratime'
> 
> I have a feeling that this inconsistent behavior may
> be due to the way our application, matlab, is
> opening
> and closing files. The fact that generating nfs
> activity, in the form of a trival read and write in
> the shell, causes the problem to disappear leads me
> to
> this conclusion. It seems like it may be buffer
> related. Is there anyway I can verify this?
> 
> Also, I've tried the 'noac' and 'nocto' options, and
> while the 'noac' option seems to decrease response
> times, the problems persist. Thank you.
> 
> RMC 
> 
> __________________________________
> Do you Yahoo!?
> The New Yahoo! Shopping - with improved product
> search
> http://shopping.yahoo.com
> 
> 
>
-------------------------------------------------------
> This SF.net email is sponsored by: SF.net Giveback
> Program.
> SourceForge.net hosts over 70,000 Open Source
> Projects.
> See the people who have HELPED US provide better
> services:
> Click here: http://sourceforge.net/supporters.php
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


__________________________________
Do you Yahoo!?
The New Yahoo! Shopping - with improved product search
http://shopping.yahoo.com


-------------------------------------------------------
This SF.net email is sponsored by OSDN developer relations
Here's your chance to show off your extensive product knowledge
We want to know what you know. Tell us and you have a chance to win $100
http://www.zoomerang.com/survey.zgi?HRPT1X3RYQNC5V4MLNSV3E54
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
