From: Patrick Boutilier <boutilpj@ednet.ns.ca>
Subject: Re: NFS/Linux/IP Chains
Date: Tue, 21 Jan 2003 08:45:13 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E2D40D9.7000808@ednet.ns.ca>
References: <NDBBKPGJGKJJGFNEEIINCENIEPAA.kwe@buffalo.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from trademart-1.ednet.ns.ca ([142.227.51.1])
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18axnC-0002eQ-00
	for <nfs@lists.sourceforge.net>; Tue, 21 Jan 2003 04:46:14 -0800
Received: from trademart-2.ednet.ns.ca ([142.227.51.61] helo=ednet.ns.ca)
	by Trademart-1.ednet.ns.ca with esmtp (TLSv1:RC4-MD5:128)
	(Exim 4.12)
	id 18axme-00073t-00
	for nfs@lists.sourceforge.net; Tue, 21 Jan 2003 08:45:40 -0400
In-Reply-To: <NDBBKPGJGKJJGFNEEIINCENIEPAA.kwe@buffalo.edu>
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

Ken,



tcpdump might help.



Ken English wrote:
> Hope I can get an assist, or if this is just a RTFM, just point me in the
> right direction. I've been working to set up NFS on a Redhat 7.3 box that
> has ipchains enabled. I am having problems pinning down the ports for some
> of the services, mountd works fine, but statd doesn't allow the "pinning"
> options provided in the howto I have been trying to use.
> 
> Any suggestions?
> 
> Thanks in advance,
> -Ken
> 
> 
> 
> -----------------------------------------------------------------------
> Kenneth W. English, Ph.D.
> Industrial Outreach Coordinator
> New York State Center for Engineering Design and Industrial Innovation
> Department of Mechanical and Aerospace Engineering
> 5 Norton Hall
> University at Buffalo
> Buffalo, NY 14260
> Phone:	(716) 645-2685 x105
> Cell:		(716)	510-5597
> Fax:	(716) 645-2684
> email: kwe@buffalo.edu
> http://www.nyscedii.buffalo.edu
> -----------------------------------------------------------------------
> 
> 
> 
> 
> -------------------------------------------------------
> This SF.NET email is sponsored by:
> SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
> http://www.vasoftware.com
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs



-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
