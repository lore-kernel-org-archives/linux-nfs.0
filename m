From: Steve Dickson <SteveD@redhat.com>
Subject: Re: NFS server not responding
Date: Thu, 04 Dec 2003 16:24:22 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FCFA606.8030809@RedHat.com>
References: <Pine.LNX.4.44.0311281257130.22389-100000@kenzo.iwr.uni-heidelberg.de>	 <shsptfch1om.fsf@charged.uio.no> <3FCF70D9.1010808@RedHat.com>	 <shsr7zk5sw4.fsf@guts.uio.no>  <3FCF86E9.2030300@RedHat.com> <1070571324.8472.2.camel@opus>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AS0wg-0005kl-OB
	for nfs@lists.sourceforge.net; Thu, 04 Dec 2003 13:23:34 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AS0wg-0003fF-BR
	for nfs@lists.sourceforge.net; Thu, 04 Dec 2003 13:23:34 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.11.6/8.11.6) with ESMTP id hB4LNV230590
	for <nfs@lists.sourceforge.net>; Thu, 4 Dec 2003 16:23:31 -0500
Received: from lacrosse.corp.redhat.com (lacrosse.corp.redhat.com [172.16.52.154])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id hB4LNV219909
	for <nfs@lists.sourceforge.net>; Thu, 4 Dec 2003 16:23:31 -0500
Received: from RedHat.com (dickson.boston.redhat.com [172.16.65.20])
	by lacrosse.corp.redhat.com (8.11.6/8.11.6) with ESMTP id hB4LNV309312
	for <nfs@lists.sourceforge.net>; Thu, 4 Dec 2003 16:23:31 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <1070571324.8472.2.camel@opus>
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

seth vidal wrote:

> Do you know if this change was in place when the 7.X kernels went from
>2.4.18 to 2.4.20?
>  
>
No it was not...

In early kernels (i.e. pre 2.4.20) RPC_RTO_MIN is not relative to HZ
    #define RPC_RTO_MIN (2)

which causes the min timeout to be too small (especially on ia64 archs).
So my patch (to the 2.4.20 kernels) made RPC_RTO_MIN relative to HZ
and increase the timeout a bit

    #define RPC_RTO_MIN (HZ/30)

Trond's patch increases the min even more (which a good thing, imho)
   
    #define RPC_RTO_MIN (HZ/10)


SteveD.



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
