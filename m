Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:11008 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753181Ab2AWVWy convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jan 2012 16:22:54 -0500
Received: from svlrsexc1-prd.hq.netapp.com (svlrsexc1-prd.hq.netapp.com [10.57.115.30])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id q0NLMsQh007385
	for <linux-nfs@vger.kernel.org>; Mon, 23 Jan 2012 13:22:54 -0800 (PST)
Message-ID: <1327353774.2628.13.camel@lade.trondhjem.org>
Subject: Re: [PATCH] SUNRPC: Add trace events to the sunrpc subsystem
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "Adamson, Dros" <Weston.Adamson@netapp.com>
Cc: linux-nfs@vger.kernel.org
Date: Mon, 23 Jan 2012 13:22:54 -0800
In-Reply-To: <7A6A4357-9C97-4402-9A4B-D2E1C2BDF5CF@netapp.com>
References: <1327081791-27455-1-git-send-email-Trond.Myklebust@netapp.com>
	 <7A6A4357-9C97-4402-9A4B-D2E1C2BDF5CF@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2012-01-23 at 12:56 -0800, Adamson, Dros wrote: 
> Are you missing a call to tracepoint_synchronize_unregister in the module exit function?

Hi Dros,

The comment section in tracepoint_probe_unregister() appears to imply
that we no longer need to do this:

/**
 * tracepoint_probe_unregister -  Disconnect a probe from a tracepoint
 * @name: tracepoint name
 * @probe: probe function pointer
 *
 * We do not need to call a synchronize_sched to make sure the probes have
 * finished running before doing a module unload, because the module unload
 * itself uses stop_machine(), which insures that every preempt disabled section
 * have finished.
 */

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

