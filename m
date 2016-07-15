Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:34705 "EHLO
	mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751887AbcGOTxN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jul 2016 15:53:13 -0400
Received: by mail-qk0-f174.google.com with SMTP id o67so111074122qke.1
        for <linux-nfs@vger.kernel.org>; Fri, 15 Jul 2016 12:53:12 -0700 (PDT)
Subject: Re: [PATCH 0/4] tracing: printk:console fix and __get_str() cleanup
To: linux-kernel@vger.kernel.org
References: <cover.1467407618.git.bristot@redhat.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        John Kacur <jkacur@redhat.com>
From: Daniel Bristot de Oliveira <bristot@redhat.com>
Message-ID: <2b29821e-c530-1d8d-0728-22ae7372916c@redhat.com>
Date: Fri, 15 Jul 2016 16:53:08 -0300
MIME-Version: 1.0
In-Reply-To: <cover.1467407618.git.bristot@redhat.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 07/01/2016 08:44 PM, Daniel Bristot de Oliveira wrote:
> This patch series fixes a problem on printk:console tracepoint
> that prints a blank line in the trace output after each printk
> message that finishes with '\n'.
> 
> It also does some cleanup on __get_str() usage, that
> was found while fixing the printk:console tracepoint.

This is just a gentle ping.

Thanks in advance!

-- Daniel

