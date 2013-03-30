Return-Path: linux-nfs-owner@vger.kernel.org
Received: from nm37-vm5.bullet.mail.bf1.yahoo.com ([72.30.238.205]:48592 "EHLO
	nm37-vm5.bullet.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754155Ab3C3L1t convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 30 Mar 2013 07:27:49 -0400
References: <1364550512-14832-1-git-send-email-oakad@yahoo.com> <1364564090.2660.303.camel@willson.li.ssimo.org>
Message-ID: <1364642465.72286.YahooMailNeo@web161301.mail.bf1.yahoo.com>
Date: Sat, 30 Mar 2013 04:21:05 -0700 (PDT)
From: Alex Dubov <oakad@yahoo.com>
Reply-To: Alex Dubov <oakad@yahoo.com>
Subject: Re: [PATCH] Fix compilation against Heimdal kerberos implementation
To: Simo Sorce <simo@redhat.com>
Cc: "steved@redhat.com" <steved@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
In-Reply-To: <1364564090.2660.303.camel@willson.li.ssimo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



----- Original Message -----

> From: Simo Sorce <simo@redhat.com>
> 
> 
> krb5_cc_retrieve_cred is available in MIT too, I would try to avoid
> using ifedfs here and come up with common code that works for both to
> avoid bugs that may cause different behavior in parallel code paths
> depending on which library is used.

> 
> This looks like just gratuitous re-indentation, I would drop it it's not
> needed and makes the patch bigger.

I did it on purpose and said so in the patch description header, because
I knew you are going to optimize it out anyway. I don't think that
iterating through every credential was ever considered a proper way to
implement check_for_taregt function.



> 
> MIT doesn't have krb5_get_err_text at all so it shouldn't be tried out
> at all if MIT is available.
> 
> I think you should ratrher add a keberos.m4 macro to check for
> krb5_get_err_text then change this to something like:

If it's not available on mit-krb5 and is deprecated on Heimdal, why bother
with krb5_get_err_text at all?
