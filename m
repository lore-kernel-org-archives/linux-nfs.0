From: Duane Ellis <duane_ellis@franklin.com>
Subject: problem: SunOS automounting rh 7.3
Date: Mon, 22 Jul 2002 13:04:23 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200207221704.NAA20632@mercury.franklin.com>
Reply-To: duane_ellis@franklin.com
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from newfrnk82.franklin.com ([63.88.59.82] helo=earth-out.franklin.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17Wgbp-0006ex-00
	for <nfs@lists.sourceforge.net>; Mon, 22 Jul 2002 10:04:33 -0700
Received: from saturn.franklin.com (IDENT:root@saturn.franklin.com [192.9.200.2])
	by earth-out.franklin.com (8.9.3/8.9.3) with ESMTP id NAA21852
	for <nfs@lists.sourceforge.net>; Mon, 22 Jul 2002 13:04:20 -0400
Received: from mercury.franklin.com (IDENT:root@mercury.franklin.com [192.9.200.250])
	by saturn.franklin.com (8.9.3/8.9.3) with ESMTP id NAA28911
	for <nfs@lists.sourceforge.net>; Mon, 22 Jul 2002 13:04:20 -0400
To: nfs@lists.sourceforge.net
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


Hi, Im stuck - the NFS & NIS Howto is not getting me anywhere.
and I've been at this for several days now with out advancing.

I'm in a mixed enviorment, I have 40+ sparcs running SunOS 4.1.3_U1
and a mix of x86 Linux boxes running RH 5.2 and 6.2, and a new machine
that is running RH 7.3

I'm having problems with the SunOS NFS automounter, when mounting 
at the root level from an SunOS machine mounting my new RH 7.3 Linux 
box.

if this is the wrong mailing list to post these questions on,
please tell me - I'm kind of stuck.

In detail my problems are:

>From a sunosXX box I can:

     cd /home/testusr 

            or to any other automount point both on the 
            new rh73 box, and any other machine on my 
            network.

	    Hence: I believe the automounter is basically
	    functioning correctly.

     Problem #1

     cd /net/rh73
	    This should let me get to the ROOT directory
	    on the new RH73 box, instead I get "bad directory"

            It's *VERY* important that i get this to work
            as many of our adminitrative scripts make use
            of this hack to take care of things.

     However, I can *MANUALLY* type

            mount rh73:/ /tmp/a/b

            which makes me think I have rh73:/etc/exports setup
	    correctly, otherwise it would not export it.

In reverse, From the rh73 box, I can

     cd /home/duane  
            or any other automount point both local
            to this machine or anyother machine
            on my network.

     cd /net/sunosXX
            Landing on the ROOT of a SUNOS machine 
            works for any SUNOS machines

     cd /net/rh52    
            Same with numerous RH 5.2 boxes I have.

     Problem #2

     cd /net/rh62   
            Problem: for some reason, I can only see
            ONE exported file system and nothing else.

IN reverse from a RH6.2 or RH5.2 box

     cd /home/testusr
     cd /net/rh73
     ... etc ...

     everything seems just fine.



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
