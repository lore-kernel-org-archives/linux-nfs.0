Return-Path: linux-nfs-owner@vger.kernel.org
Received: from tirith.ics.muni.cz ([147.251.4.36]:47157 "EHLO
	tirith.ics.muni.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755698Ab2LMO4Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Dec 2012 09:56:25 -0500
Date: Thu, 13 Dec 2012 15:56:21 +0100
From: Lukas Hejtmanek <xhejtman@gmail.com>
To: Fred Isaman <faisaman4@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: local_lock mount option
Message-ID: <20121213145621.GB1045@ics.muni.cz>
References: <20121213133554.GO10897@ics.muni.cz>
 <CADnza44SJ0JZN05OtMZcjsm+NwdMVPGTa2f2vG9TbpUJR_B4Zw@mail.gmail.com>
 <20121213142336.GP10897@ics.muni.cz>
 <CADnza44SGwAJTJ8sFnAOoLHRPp1Mt9pJKk-scWmrigxD2G=zpQ@mail.gmail.com>
 <20121213144025.GA1045@ics.muni.cz>
 <CADnza45K-LgvNDt1_AoybesMobwsnw=vGX9D4wkvwKLKMkes5A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
In-Reply-To: <CADnza45K-LgvNDt1_AoybesMobwsnw=vGX9D4wkvwKLKMkes5A@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 13, 2012 at 09:48:25AM -0500, Fred Isaman wrote:
> The idea is that delegations are a better way to decide whether the
> client should cache locks.

well, but I need to fake locks on client, i.e., client's lock always succeeds
independently of NFS server. I know that's wrong approchach but until I got
fix for NFS+CXFS, I dont' see any other option. And I believe that
local_locks=any does exactly what I need.

-- 
Luká¹ Hejtmánek
