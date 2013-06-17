Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ob0-f182.google.com ([209.85.214.182]:43615 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750903Ab3FQOmu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Jun 2013 10:42:50 -0400
Received: by mail-ob0-f182.google.com with SMTP id va7so3202608obc.41
        for <linux-nfs@vger.kernel.org>; Mon, 17 Jun 2013 07:42:49 -0700 (PDT)
Received: from ?IPv6:2001:470:d:51c::8924:fefd? ([2001:470:d:51c::8924:fefd])
        by mx.google.com with ESMTPSA id ps5sm17098414oeb.8.2013.06.17.07.42.47
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 17 Jun 2013 07:42:48 -0700 (PDT)
Message-ID: <51BF2066.8070102@gmail.com>
Date: Mon, 17 Jun 2013 08:42:46 -0600
From: John Haiducek <jhaiduce@gmail.com>
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: Re: Can't mount NFSv4 with kerberos on Debian Wheezy
References: <51BF2014.2050809@gmail.com>
In-Reply-To: <51BF2014.2050809@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 06/17/2013 08:23 AM, Chuck Lever wrote:
>  Is rpc.svcgssd running?

Yes, and with the same verbosity as rpc.gssd (-vvv).

John

