From: Ian Thurlbeck <ian@stams.strath.ac.uk>
Subject: Re: Strange delays on NFS server
Date: Wed, 11 Aug 2004 17:08:45 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <411A448D.3080205@stams.strath.ac.uk>
References: <4119FB15.7010205@stams.strath.ac.uk> <411A17F2.2060203@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Buven-0007SV-O2
	for nfs@lists.sourceforge.net; Wed, 11 Aug 2004 09:08:53 -0700
Received: from vif-img1.cc.strath.ac.uk ([130.159.248.61] helo=khafre.cc.strath.ac.uk)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.34)
	id 1Buven-0000ag-8q
	for nfs@lists.sourceforge.net; Wed, 11 Aug 2004 09:08:53 -0700
Received: from dunnet.stams.strath.ac.uk ([130.159.240.95]:47043)
	by khafre.cc.strath.ac.uk with smtp (Exim 4.20 #1)
	id 1Buveg-0000x5-1M
	for <nfs@lists.sourceforge.net>; Wed, 11 Aug 2004 17:08:46 +0100
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <411A17F2.2060203@RedHat.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Steve Dickson wrote:
> 
> 
> Ian Thurlbeck wrote:
> 
>> I am getting strange delays on our NFS server. Everything will
>> be fine for maybe 5 to 10 minutes, then saving a small text file
>> from a client machine will suddenly take 15 seconds or more.
>> Similarly, mozilla will pause accessing a page for ages ~30secs
>> (I assume it's poking about in ~/.mozilla). Everything pops back to 
>> normal afterwards. NFS server is lightly used at the moment.
> 
> 
> Boy... it sure sounds to me like some type of daemon or something is 
> starting up
> that is bring the machine to its knees... . Would it be possible to have 
> a top -i running
> on the server when this pause occurs?
> 
> SteveD.
> 

OK, I've been running "top -d 1 -i" and trying to see what comes up when
the server freezes. I caught one instance where a delay coincided
with about 15 nfsd + 1 kjournald process appearing in the top
display. I'm simultaneously looking at a graphical network tool to try
and see the traffic going to the server - anyone got a better suggestion?

Tomorrow I'll batch top to log to a file and get some users to
note the exact time of any delays (using the ntp-synced clocks) and
see if I can see any correlation.

I'll report back with any findings.

Many thanks

Ian
-- 
Ian Thurlbeck                http://www.stams.strath.ac.uk/
Statistics and Modelling Science, University of Strathclyde
Livingstone Tower, 26 Richmond Street, Glasgow, UK,  G1 1XH
Tel: +44 (0)141 548 3667           Fax: +44 (0)141 552 2079



-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
