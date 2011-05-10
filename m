Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:24980 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932085Ab1EJMja (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 May 2011 08:39:30 -0400
Message-ID: <4DC93200.3070706@netapp.com>
Date: Tue, 10 May 2011 08:39:28 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: NFSD Secinfo no name
References: <4DC43CE7.7070705@netapp.com> <20110510005931.GD3600@fieldses.org>
In-Reply-To: <20110510005931.GD3600@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 05/09/2011 08:59 PM, J. Bruce Fields wrote:
> On Fri, May 06, 2011 at 02:24:39PM -0400, Bryan Schumaker wrote:
>> Hi Bruce,
>>
>> On the call yesterday you asked me to double check that secinfo no name still works in NFSD.  It does still work for me.
> 
> My real question was whether the bug you reported here:
> 
> 	http://marc.info/?l=linux-nfs&m=130192462122087&w=2
> 
> appears to have been fixed (in my for-2.6.40 branch) to your
> satisfaction?

Yes it has.  That's what I was trying to answer, sorry if I wasn't clear.

> 
> --b.

