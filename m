From: Greg Banks <gnb@sgi.com>
Subject: Re: issues with project quota over nfs
Date: Mon, 16 Mar 2009 14:03:37 +1100
Message-ID: <49BDC189.10104@sgi.com>
References: <AD300F292705ED4089373955E129C1780491E77D@RBSJX.ad.redback.com> <20090315205516.GB26627@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: "J. Bruce Fields" <bfields@fieldses.org>,
	NFS list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay3.sgi.com ([192.48.171.31]:39295 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752604AbZCPC6z (ORCPT
	<rfc822;@relay.corp.sgi.com:linux-nfs@vger.kernel.org>);
	Sun, 15 Mar 2009 22:58:55 -0400
In-Reply-To: <20090315205516.GB26627@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

J. Bruce Fields wrote:
> On Fri, Mar 13, 2009 at 09:59:26AM -0700, Brian Wince wrote:
>   
>> All,
>> We have a Quad-core server running gentoo 2.6.27-r7 that is used as an nfs server for a xfs partition.
>> We are using project quota's on directories within this partition and exporting this.
>> When a client tries to untar in the dir with project quotas set and reaches the quota limit the load on the NFS server goes up dramatically and stays like this for a few minutes after the tar has gone through trying to write all of it files and failing due to quota limit exceeded.
>>  
>> Is this a known issue and if so is there anything that can be done to resolve this.
>>  
>> We do not see this issue if on the locally mounted partition. This only happens over NFS.
>>  
>> Please let me know if you need more information or if this should be addressed on a different list.
>>     
>
> It doesn't sounds familiar to me.  Might also be worth cc:'ing xfs
> people.
>
>
>   
Oh dear.  Brian asked it there frst, and I redirected him here.  In the
absence of network traces, it smelt to me like the old client problem
where errors like ENOSPC or EDQUOT during writeback were only returned
to the app on close() and not the next write(), thus causing clients
which exceed  quota during long streaming writes pointlessly to send a
lot of data to the server all of which is dropped on the server.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
the brightly coloured sporks of revolution.
I don't speak for SGI.

