Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59590 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750705AbcDNTIZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Apr 2016 15:08:25 -0400
Date: Thu, 14 Apr 2016 15:08:22 -0400 (EDT)
From: Benjamin Coddington <bcodding@redhat.com>
To: Ziemowit PIerzycki <ziemowit@pierzycki.com>
cc: linux-nfs@vger.kernel.org
Subject: Re: What is a 10.10.10.20-man process?
In-Reply-To: <loom.20160414T205732-249@post.gmane.org>
Message-ID: <alpine.OSX.2.19.9992.1604141506460.55780@planck>
References: <loom.20160414T205732-249@post.gmane.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 14 Apr 2016, Ziemowit PIerzycki wrote:

> I have a strange issue when NFS4 mounts to a Netapp filer freeze on my Linux
> KVMs.  Looking over few things I noticed a process "10.10.10.20-man" is in D
> state but I can't find anything information about it.  Mainly because
> 10.10.10.20 is the IP of the filer and searching for "-man" is too generic.
>
> Why would this process be frozen?

This is the nfs4 state manager process.  What's in the file:
/proc/<pid of that process>/stack

Ben
