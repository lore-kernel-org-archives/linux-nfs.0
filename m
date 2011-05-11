Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:28257 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754934Ab1EKPrc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 May 2011 11:47:32 -0400
Message-ID: <4DCAC586.2040205@panasas.com>
Date: Wed, 11 May 2011 13:21:10 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: chao liu <lcnrchpc@gmail.com>
CC: bwickman@citi.umich.edu, linux-nfs@vger.kernel.org
Subject: Re: some questions about NFSv4.1_Directory_Delegation
References: <BANLkTik8xfnPCc+z_S_jBU5o6mOYUkOrrQ@mail.gmail.com>
In-Reply-To: <BANLkTik8xfnPCc+z_S_jBU5o6mOYUkOrrQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-05-11 05:30, chao liu wrote:
> *hi  everyone,*
> *           **Benny and **bwickman**,*
> *           i have read the
> article https://wiki.linux-nfs.org/wiki/index.php/CITI_Experience_with_Directory_Delegations 
> carefully,*
> *           and i checked the latest  source code in git hub,  i can't
> find the code about directory delegation , so i got two questions to ask,. *ny
> *
> *
> *           To Benny,  thank you  very much,  do you think that what are
> the most difficulties or problems to implement  Directory_Delegation in
>  pnfs?*

Directory delegations are not related to pNFS but rather to NFSv4.1.
I wasn't involved in their experimental implementation in CITI so I
don't know exactly what were their challenges.  I can only guess that
the harder parts were dealing with the name cache rather than
implementing the related NFSv4.1 code.

As far as I know, the benefits demonstrated so far are not good enough
to justify the added complexity.

Benny

> *
> *
> *           To the author who wrote the article(the author may know
> bwickman), also thanks very much, you said that you have implemented *
> *           Directory_Delegation prototype, how can i find the sourcecode? *
> *           *
> *
> *
> 
> 
>    

