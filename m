From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [PATCH] nfsd: use nfs client rpc callback program
Date: Thu, 18 Sep 2008 15:05:58 -0500
Message-ID: <48D2B4A6.9000207@panasas.com>
References: <48D15DF0.4000406@panasas.com> <20080917231018.GA5723@fieldses.org>	<48D193EE.2020805@panasas.com> <48D19C74.8000303@panasas.com> <48D2AAF7.6060808@panasas.com> <48D2AF61.7030500@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, pnfs mailing list <pnfs@linux-nfs.org>,
	Olga Kornievskaia <aglo@citi.umich.edu>
To: Peter Staubach <staubach@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:9571 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755978AbYIRUF2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Sep 2008 16:05:28 -0400
In-Reply-To: <48D2AF61.7030500@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sep. 18, 2008, 14:43 -0500, Peter Staubach <staubach@redhat.com> wrote:
[snip]
>> +	cb_program = kzalloc(sizeof(struct rpc_program) +
>> +			     sizeof(struct rpc_stat), GFP_KERNEL);
>>   
> 
> Ugg.  What about defining a struct which contains an rpc_program
> followed by an rpc_stat and then allocate and free that?  This
> seems a little, unclean, to me.
> 
>        ps
> 

Sure. No problem.
Thanks for reviewing this.

Benny
