From: Steve Dickson <SteveD@redhat.com>
Subject: Re: NFSv3 ACL status?
Date: Fri, 13 Aug 2004 10:45:32 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <411CD40C.6040309@RedHat.com>
References: <482A3FA0050D21419C269D13989C611302B07DC1@lavender-fe.eng.netapp.com> <20040813085230.GC12123@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: "Lever, Charles" <cel@netapp.com>, Peter Astrand <peter@cendio.se>,
        nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BvdIv-0007UE-Oq
	for nfs@lists.sourceforge.net; Fri, 13 Aug 2004 07:45:13 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BvdIv-0006QV-CV
	for nfs@lists.sourceforge.net; Fri, 13 Aug 2004 07:45:13 -0700
To: Olaf Kirch <okir@suse.de>
In-Reply-To: <20040813085230.GC12123@suse.de>
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



Olaf Kirch wrote:

>On Thu, Aug 12, 2004 at 08:00:56AM -0700, Lever, Charles wrote:
>  
>
>>i believe what ag's patch set provides is "POSIX ACL support" which
>>means he has added the generic file system interfaces needed to support
>>ACLs as they are described in the POSIX standards.  "Solaris ACL
>>support" means using the Sun-defined NFS side-band protocol to access
>>and modify POSIX ACLs via an NFS client.
>>    
>>
>
>No; Andreas' patches implement the Solaris ACL side-band protocol for
>NFSv3.  These patches are in the suse kernels; I don't know whether or
>not they are in any redhat kernels.
>  
>
They are in RHEL kernels, not FC ones...

SteveD.


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
