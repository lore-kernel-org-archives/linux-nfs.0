From: ms419@freezone.co.uk
Subject: FIXED: F_SETLK failed, file already locked by pid 0
Date: Thu, 26 Aug 2004 23:54:41 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <F84844C7-F7F5-11D8-9028-000A95C71776@freezone.co.uk>
References: <A4B2A13E-F48D-11D8-A02C-000A95C71776@freezone.co.uk> <1093220956.4718.23.camel@lade.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v613)
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C0adL-0005x3-Qo
	for nfs@lists.sourceforge.net; Thu, 26 Aug 2004 23:54:47 -0700
Received: from defout.telus.net ([199.185.220.240] helo=priv-edtnes33.telusplanet.net)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.34)
	id 1C0adK-0002iE-BB
	for nfs@lists.sourceforge.net; Thu, 26 Aug 2004 23:54:47 -0700
Received: from tor.lat ([142.179.38.145]) by priv-edtnes33.telusplanet.net
          (InterMail vM.6.01.03.02 201-2131-111-104-20040324) with ESMTP
          id <20040827065434.WHTH11839.priv-edtnes33.telusplanet.net@tor.lat>
          for <nfs@lists.sourceforge.net>; Fri, 27 Aug 2004 00:54:34 -0600
Received: from [192.168.179.43] (fis.lat [192.168.179.43])
	by tor.lat (Postfix) with ESMTP id 83870120B6C
	for <nfs@lists.sourceforge.net>; Thu, 26 Aug 2004 23:54:28 -0700 (PDT)
In-Reply-To: <1093220956.4718.23.camel@lade.trondhjem.org>
To: nfs@lists.sourceforge.net
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

On Aug 22, 2004, at 5:29 PM, Trond Myklebust wrote:

> P=E5 su , 22/08/2004 klokka 18:50, skreiv ms419@freezone.co.uk:
>> I suspect locking isn't working:
>>
>> F_SETLK failed, file already locked by pid 0
>>
>> Pointers to diagnostic  information, configuration, & documentation=20=

>> much appreciated!
>
> NFS-HOWTO:
> 	http://nfs.sourceforge.net/nfs-howto/
>
> NFS-FAQ:
> 	http://nfs.sourceforge.net/
>
>> Why isn't locking working?
>
> No-one will be able to answer this until you give at least a minimum =
of
> details on how your system is set up. For instance, details on how the
> network is set up, whether rpc.statd is running as it should, whether
> 'rpcinfo -p' works from both server to client and from client to=20
> server,
> etc.

Thank you very much for your generous help, Trond - unfortunately, I am=20=

a moron : P

The HOWTO plainly states statd must be running on the server _&=20
client_. statd wasn't running on my client. Now that it is, locking=20
works. So much for having read all the docs : P

Don't know how I always turn a simple problem into a marathon=20
head-scratch.

Thanks again!

Jack



-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
