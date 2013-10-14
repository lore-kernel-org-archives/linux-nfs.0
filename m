Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:34197 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754652Ab3JNPXC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Oct 2013 11:23:02 -0400
From: Weston Andros Adamson <dros@netapp.com>
To: Frank Filz <ffilzlnx@mindspring.com>
CC: Anna Schumaker <schumaker.anna@gmail.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>,
        Ganesha NFS List <nfs-ganesha-devel@lists.sourceforge.net>
Subject: Re: [PATCH] NFS: Add support for multiple sec= mount options
Date: Mon, 14 Oct 2013 15:23:00 +0000
Message-ID: <B072FFC7-EB7C-413C-958A-7CB3AED96FEF@netapp.com>
References: <1381517062-11267-1-git-send-email-dros@netapp.com>
 <20131011210104.GD22160@fieldses.org> <525BEDA8.3000309@gmail.com>
 <07F13874-0BD4-4A90-BB98-B902A8D00065@netapp.com>
 <02a801cec8f0$b208f200$161ad600$@mindspring.com>
In-Reply-To: <02a801cec8f0$b208f200$161ad600$@mindspring.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Oct 14, 2013, at 11:18 AM, Frank Filz <ffilzlnx@mindspring.com> wrote:

>>>>> I wrote a script to verify that I haven't broken anything, it tests
>>>>> all vers= and sec= combinations against a server with the exports:
>>>> 
>>>> Is the script something that could be added to Anna's or my regular
>>>> regression testing?
>>> 
>>> I looked over the script Friday and I don't think it'll be too
>>> difficult to work in to my Jenkins stuff :)
>> 
>> I have a new copy of the script that allows (almost) everything to be
> passed
>> in as an environment variable.
>> 
>> I'll hand that off to you later today.
> 
> Is this script something that would work well with Linux client against an
> arbitrary server? We will eventually need to test the security negotiation
> stuff with Ganesha.
> 
> Frank
> 
> 

Yes, this script should work well for you. We'll make sure that it's easy to run as a standalone thing too.

-dros