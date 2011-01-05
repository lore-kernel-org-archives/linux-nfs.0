From: Bryan Schumaker <bjschuma@netapp.com>
Subject: Re: [PATCH v2 0/5] Add secinfo to the NFS client
Date: Wed, 05 Jan 2011 16:50:56 -0500
Message-ID: <4D24E7C0.9010706@netapp.com>
References: <4D24CB2E.5030207@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"Myklebust, Trond" <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48789 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751312Ab1AEVu6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Jan 2011 16:50:58 -0500
In-Reply-To: <4D24CB2E.5030207@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I forgot to mention that these apply on top of Tronds "devel" branch of nfs-2.6.git.

-Bryan

On 01/05/2011 02:49 PM, Bryan Schumaker wrote:
> These patches will add the secinfo procedure to the NFS client 
> and do some cleanup along the way.  The final result will should
> be able to cross mountpoints using a different form of security
> and auto-detect the security of an initial NFS v4 mount.
> 
> v2:
>  - Add more details about the call_sync improvement
>  - Don't initialize global constant function pointers to NULL
> 
> Bryan
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

