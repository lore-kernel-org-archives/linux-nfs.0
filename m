Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:22337 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751352Ab2CUThO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 21 Mar 2012 15:37:14 -0400
Message-ID: <4F6A2DE8.6060403@netapp.com>
Date: Wed, 21 Mar 2012 15:37:12 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: krb5 failures in recent nfs-for-next
References: <20120321192448.GB11222@fieldses.org>
In-Reply-To: <20120321192448.GB11222@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/21/2012 03:24 PM, J. Bruce Fields wrote:

> Have you been doing any krb5 testing?


Not yet.  It's still on my Jenkins todo list, but I haven't gotten around to it yet.  Sounds like we need it, though, so I'll try working on it soon.

- Bryan

> 
> I'm seeing the client crash as of nfs-for-next, and haven't been able to
> get any debugging out of it so far.
> 
> --b.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


