From: Steve Dickson <SteveD@redhat.com>
Subject: Re: Re: "nfs warning: mount version older than kernel" reported
 for 2.6.4 kernel on Fedora Core 1.0
Date: Fri, 19 Mar 2004 17:30:19 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <405B747B.2080604@RedHat.com>
References: <41089CB27BD8D24E8385C8003EDAF7AB084833@karl.alexa.com> <20040319184931.GF29237@perlsupport.com> <1079725155.2530.30.camel@lade.trondhjem.org> <20040319200314.GG29237@perlsupport.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Guolin Cheng <guolin@alexa.com>,
        "NFSUserList (E-mail)" <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B4SVe-0000W9-Aa
	for nfs@lists.sourceforge.net; Fri, 19 Mar 2004 14:30:34 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1B4SVb-0005cn-Re
	for nfs@lists.sourceforge.net; Fri, 19 Mar 2004 14:30:31 -0800
To: Chip Salzenberg <chip@pobox.com>
In-Reply-To: <20040319200314.GG29237@perlsupport.com>
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

Chip Salzenberg wrote:

>According to Trond Myklebust:
>  
>
>>(BTW: we're *still* waiting to hear from this list about including
>>the RPCSEC_GSS + NFSv4 support daemons into the official nfs-utils)
>>    
>>
>
>Well, I'd be glad to look at patches for inclusion in Debian's
>nfs-utils.  I'd probably put them in CVS but on a branch.
>  
>
You might want to take a look at the  nfs-utils on my people page
(people.redhat.com/steved/nfs/nfsv4). Its got both the rpc.idmapd
and rpc.gssed integrated. The util-linux on the same page also
had the v4 mount hooks needed as well....

SteveD.



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
