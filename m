From: "Iyer, Rahul" <Rahul.Iyer@netapp.com>
Subject: Re: How to specify sctp protocol?
Date: Mon, 29 Oct 2007 03:12:07 -0700
Message-ID: <7619F3097FAB384287CF636FF92D0CA10B605CDC@exsvl01.hq.netapp.com>
References: <200710291746.15411.huangxiong@uit.com.cn><7619F3097FAB384287CF636FF92D0CA10B605CDB@exsvl01.hq.netapp.com>
	<200710291808.45838.huangxiong@uit.com.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Cc: nfs@lists.sourceforge.net
To: "Huang Xiong" <huangxiong@uit.com.cn>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ImRbO-0003o3-33
	for nfs@lists.sourceforge.net; Mon, 29 Oct 2007 03:12:10 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ImRbT-0004Ok-BV
	for nfs@lists.sourceforge.net; Mon, 29 Oct 2007 03:12:15 -0700
In-Reply-To: <200710291808.45838.huangxiong@uit.com.cn>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

No, I meant the Linux implementation doesn't support it yet. It supports TCP and UDP transports over IPv4. IPv6 is being added.
-Rahul


> -----Original Message-----
> From: Huang Xiong [mailto:huangxiong@uit.com.cn] 
> Sent: Monday, October 29, 2007 3:39 PM
> To: Iyer, Rahul
> Cc: nfs@lists.sourceforge.net
> Subject: Re: [NFS] How to specify sctp protocol?
> 
> Perhaps I understand wrong. Please see below:
> 
> 
> From "http://www.ietf.org/rfc/rfc3530.txt"
> 
> 3.1.  Ports and Transports
> 
>    Historically, NFS version 2 and version 3 servers have resided on
>    port 2049.  The registered port 2049 [RFC3232] for the NFS protocol
>    should be the default configuration.  Using the registered port for
>    NFS services means the NFS client will not need to use the RPC
>    binding protocols as described in [RFC1833]; this will allow NFS to
>    transit firewalls.
> 
>    Where an NFS version 4 implementation supports operation 
> over the IP
>    network protocol, the supported transports between NFS and 
> IP MUST be
>    among the IETF-approved congestion control transport 
> protocols, which
>    include TCP and SCTP.  To enhance the possibilities for
>    interoperability, an NFS version 4 implementation MUST support
>    operation over the TCP transport protocol, at least until such time
>    as a standards track RFC revises this requirement to use a 
> different
>    IETF-approved congestion control transport protocol.
> 
> 
> 
> 在 星期一 29 十月 2007 17:59，Iyer, Rahul 写道：
> > I don't believe you can. I don't think NFS over SCTP is 
> supported yet.
> > -Rahul
> >
> > > -----Original Message-----
> > > From: Huang Xiong [mailto:huangxiong@uit.com.cn]
> > > Sent: Monday, October 29, 2007 3:16 PM
> > > To: nfs@lists.sourceforge.net
> > > Subject: [NFS] How to specify sctp protocol?
> > >
> > > Hello folks,
> > >
> > > As NFSv4 supports SCTP protocol,  how to specify this protocol in 
> > > application?
> > > or need to add some option appened with mount the NFS shares?
> > >
> > > My underlying filesystem is GFS, which uses SCTP for cluster 
> > > internode communication. I wonder that I have to specify the SCTP 
> > > option when I try to mount NFS share based on GFS.
> > >
> > > I've been trying to find some useful information but with 
> no success.
> > > Anyone having an idea or experienced the same problem?
> > > Maybe I can provide more useful information on this.
> > >
> > > Thanks in advance.
> > > Phillip
> > >
> > > --------------------------------------------------------------
> > > -----------
> > > This SF.net email is sponsored by: Splunk Inc.
> > > Still grepping through log files to find problems?  Stop.
> > > Now Search log events and configuration files using AJAX and a 
> > > browser.
> > > Download your FREE copy of Splunk now >> http://get.splunk.com/ 
> > > _______________________________________________
> > > NFS maillist  -  NFS@lists.sourceforge.net 
> > > https://lists.sourceforge.net/lists/listinfo/nfs
> 
> 

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
