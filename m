From: Marc Schmitt <mschmitt@inf.ethz.ch>
Subject: Re: nfs_statfs: statfs error = 116
Date: 21 Sep 2003 15:38:31 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1064151511.2042.44.camel@localhost>
References: <3F698142.6070404@inf.ethz.ch>  <3F69B7FB.1050505@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A14Un-0007IP-00
	for <nfs@lists.sourceforge.net>; Sun, 21 Sep 2003 06:43:26 -0700
Received: from mxout.hispeed.ch ([62.2.95.247] helo=smtp.hispeed.ch)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 1A14Um-0007mv-Of
	for nfs@lists.sourceforge.net; Sun, 21 Sep 2003 06:43:25 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <3F69B7FB.1050505@RedHat.com>
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

On Thu, 2003-09-18 at 15:49, Steve Dickson wrote:
> Marc Schmitt wrote:
> 
> >
> > My questions are:
> >
> > - Is this a race? 
> 
> It sounds to me like it could be be a server issue under
> a very heavy load...  How many nfsd are you running? Try
> increasing the number to see if that helps....

I remembered that the NFS-HowTo refers to this by giving a rule how to
detremine if one needs more nfsd running, the HowTo says
(http://nfs.sourceforge.net/nfs-howto/performance.html section 5.6):
"If you are using a 2.4 or higher kernel and you want to see how heavily
each nfsd thread is being used, you can look at the file
/proc/net/rpc/nfsd. The last ten numbers on the th line in that file
indicate the number of seconds that the thread usage was at that
percentage of the maximum allowable. If you have a large number in the
top three deciles, you may wish to increase the number of nfsd
instances."

The th line looks like this (after changing to 64 nfsd, obviously):
th 64 6121728 134012.900 61327.500 34092.130 21573.980 22513.750
8121.200 5826.550 4062.540 3129.340 26975.820

The last ten numbers are then:
134012.900 61327.500 34092.130 21573.980 22513.750 8121.200 5826.550
4062.540 3129.340 26975.820

But what is referred by "top three deciles"? I have an english
understanding problem here, sorry. I looked up the word decile and it
means what I guessed: one tenth or one unit out of ten. Does that mean
that the top three deciles are:
134012.900 61327.500 34092.130 ?

That does not make sense to me, because it says "If you have a large
number...", it refers to "a" number or should it read "If you have a
large number amongst the top...".

And then what is "the thread usage at that percentage of the maximum
allowable"? Which value refers to the maximum? 6121728?

Can someone please try to explain this to me, I'm pretty much lost...

TIA

	Marc










-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
