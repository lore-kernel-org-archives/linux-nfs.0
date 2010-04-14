Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14296 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755505Ab0DNTgD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Apr 2010 15:36:03 -0400
Message-ID: <4BC61921.9060808@RedHat.com>
Date: Wed, 14 Apr 2010 15:36:01 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/22] Add support for more RPCSEC_GSS/krb5 enctypes
References: <1271266618-26016-1-git-send-email-Trond.Myklebust@netapp.com>	 <20100414174703.GA26724@fieldses.org> <1271267687.22566.16.camel@localhost.localdomain>
In-Reply-To: <1271267687.22566.16.camel@localhost.localdomain>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 04/14/2010 01:54 PM, Trond Myklebust wrote:
> On Wed, 2010-04-14 at 13:47 -0400, J. Bruce Fields wrote: 
>> On Wed, Apr 14, 2010 at 01:36:36PM -0400, Trond Myklebust wrote:
>>> The following patches have been queued up in the nfs-for-2.6.35 branch
>>> on git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git.
>>
>> How are you testing this?  (Is there code for the userspace side?)
> 
> SteveD has promised to release the nfs-utils patches soon.
Just posted them...

> 
> He is also the one responsible for testing these patches. All I did was
> clean them up, and change the enctype advertising so that we pass that
> information directly in the upcall instead of adding another pseudofile
> in rpc_pipefs.
I used the cthon tests to test both the user space and kernel patches 
on a 2.6.32, 2.6.33 and 2.6.34 kernels. Plus, other than Trond's minor 
tweaks, these were the same patches Peter Staubach brought to 
Connectathon this year... 

steved.
