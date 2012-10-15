Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40511 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750953Ab2JORNc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Oct 2012 13:13:32 -0400
Message-ID: <507C4435.4050103@RedHat.com>
Date: Mon, 15 Oct 2012 13:13:25 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Ivan Romanov <drizt@land.ru>
CC: linux-nfs@vger.kernel.org
Subject: Re: exportfs crash with long path
References: <1349708828.1183.5.camel@lix>
In-Reply-To: <1349708828.1183.5.camel@lix>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/10/12 11:07, Ivan Romanov wrote:
> Hello. I opened a bug with nfs-utils on Redhat Bugzilla. And got an
> advice to email upstream. So I just repeat my bug text with a patch.
> 
> How reproducible:
> always
> 
> Steps to Reproduce:
> # mkdir -p /home/kudinae/Общедоступные
> # echo '/home/kudinae/Общедоступные oek-1(rw,sync,no_wdelay,no_root_squash,no_subtree_check)' > /etc/exports
> # exportfs -a
> Segmentation fault
> 
> I've obtained the sources. So a crush happens on export.c:293. variable
> pos has negative value. I think problem into strtoint and export_hash
> functions. strtoint has unsigned type and always returns positive value
> but export_hash impicity cast it to signed int. So it is possible to
> get negative value. I wrote patch to fix this.
> 
> Original Red Hat bug
> https://bugzilla.redhat.com/show_bug.cgi?id=863054
> 
Committed...

steved.
