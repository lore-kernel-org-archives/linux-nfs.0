From: Steve Dickson <SteveD@RedHat.com>
Subject: Re: NFS/UDP slow read, lost fragments
Date: Mon, 13 Oct 2003 21:20:59 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3F8B4F7B.4010907@RedHat.com>
References: <Pine.LNX.4.44.0309251019170.28586-100000@localhost.localdomain> <20030925174426.B787@muppet.kendall.corp.akamai.com> <shs1xu430p2.fsf@charged.uio.no> <20030926170759.H787@muppet.kendall.corp.akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A9Dsd-0006z5-00
	for <nfs@lists.sourceforge.net>; Mon, 13 Oct 2003 18:21:43 -0700
Received: from host-64-179-20-100.man.choiceone.net ([64.179.20.100] helo=Odyssey.Home.4Dicksons.Org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 1A9Dsc-0005vS-QM
	for nfs@lists.sourceforge.net; Mon, 13 Oct 2003 18:21:42 -0700
To: Brian Mancuso <bmancuso@akamai.com>
In-Reply-To: <20030926170759.H787@muppet.kendall.corp.akamai.com>
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

Brian Mancuso wrote:

>On Thu, Sep 25, 2003 at 04:31:05PM -0700, Trond Myklebust wrote:
>: 
>:Could people give it a try?
>: 
> Here is a patch (against linux-2.4.23-pre5 with your patch) that implements this (you might
>know of a cleaner way of doing this..):
>  
>
I've done some testing with both of these patches and here is
what I've found.... The test consisted of 10 client threads reading 10
different 100mg files on the same filesystem simultaneously. The
machines were duel x86 using private 100bt network.

I used the linux-2.4.23-pre7 kernel with both Trond's and Brian's
patches. The test was done with hard and soft mounts using v3 over
UDP.  Here are the results:

linux-2.4.23-pre7
Soft mount:
EIO calls      retrans   rate
0   128042     2105      6.20Mbps to 6.08Mbps
0   128040     1916      6.28Mbps to 6.09Mbps
0   128044     1936      6.37Mbps to 6.12Mbps
Hard mount:
    128048     1995      6.29Mbp  to 6.09Mbps
    128033     2075      6.21Mbps to 6.07Mbps
    128037     2015      6.23Mbps to 6.10Mbps

with Trond's patch
Soft mount:
EIO calls      retrans   rate
0   128038     1954      6.25Mbps to 6.12Mbps
0   128039     1789      6.32Mbp  to 6.14Mbps
0   128042     1853      6.25Mbps to 6.13Mbps
Hard mount:
    128039     1880      6.28Mbps to 6.11Mbps
    128042     2019      6.29Mbps to 6.12Mbps
    128042     1883      6.32Mbps to 6.14Mbps

with Trond's and Brian's patch
Soft mount:
EIO calls      retrans   rate
0   128036     1943      6.31Mbps to 6.14Mbps
0   128042     1802      6.35Mbps to 6.19Mbps
0   128047     1782      6.35Mbps to 6.14Mbps
Hard mount:
    128042     1953      6.28Mbps to 6.10Mbps
    128038     1752      6.48Mbps to 6.17Mbps
    128034     1978      6.26Mbps to 6.11Mbps

As you can see the patches does help a little bit but
but not as much as I would expect.... Maybe it was the
type of testes ran or maybe I didn't run the tests long enough
(each test ran for about ~2mins) or maybe my expectations
are too high... But it just doesn't seem that these patches really
help that much in bringing down the retransmissions...

SteveD.






-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
SourceForge.net hosts over 70,000 Open Source Projects.
See the people who have HELPED US provide better services:
Click here: http://sourceforge.net/supporters.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
