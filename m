From: Marc Schmitt <mschmitt@inf.ethz.ch>
Subject: Re: nfs_statfs: statfs error = 116
Date: Fri, 19 Sep 2003 11:27:42 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F6ACC0E.5020904@inf.ethz.ch>
References: <3F698142.6070404@inf.ethz.ch>	<3F69B7FB.1050505@RedHat.com>	<1063913183.1553.25.camel@localhost> <16234.19528.624551.573433@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A0HYJ-0003Ly-00
	for <nfs@lists.sourceforge.net>; Fri, 19 Sep 2003 02:27:47 -0700
Received: from medoc.inf.ethz.ch ([129.132.178.200])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A0HYI-0004MB-HD
	for nfs@lists.sourceforge.net; Fri, 19 Sep 2003 02:27:46 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16234.19528.624551.573433@notabene.cse.unsw.edu.au>
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

Neil Brown wrote:

>On  September 18, mschmitt@inf.ethz.ch wrote:
>  
>
>>A user has found a bug that appears when checking out a big subversion
>>repository on the same server over NFS, it will always timeout upon this
>>huge amount of file manipulations and the checkout fails. He then
>>reproduced the issue with a small script that basicly loops over those
>>four commands:
>>
>>rename ("old/bla", "new/bla")
>>stat("new,bla",..)
>>chmod("new/bla")
>>rename ("new/bla", "old/bla")
>>
>>Before 1000 iterations the script returns: Error setting new/bla to
>>read-only! We'll try to narrow this down on the test cluster, too. One
>>particularity has been found already: the bug only appears if
>>the renaming takes place over directory boundries.
>>    
>>
>
>Sounds like you are using the "subtree_check" export flag on that
>export (possibly implicitly).  You don't want to.  i.e. add
>"no_subtree_check" after reading "man exports"
>  
>
Excellent, that worked. Thank you very much.

    Marc



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
