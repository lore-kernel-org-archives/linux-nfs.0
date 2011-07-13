Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46369 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932216Ab1GMRLE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 13 Jul 2011 13:11:04 -0400
Message-ID: <4E1DD1A0.5000700@RedHat.com>
Date: Wed, 13 Jul 2011 13:10:56 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Benjamin Coddington <bcodding@uvm.edu>
CC: linux-nfs@vger.kernel.org
Subject: Re: multiple service identities for svcgssd
References: <3EA8A380-460C-4CDC-9591-7034D2E38D93@uvm.edu>
In-Reply-To: <3EA8A380-460C-4CDC-9591-7034D2E38D93@uvm.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 07/13/2011 12:03 PM, Benjamin Coddington wrote:
> I am working on a linux NFS cluster that requires a single svcgssd to establish contexts under multiple service names.
> 
> In this scenario, svcgssd can be called with "-n" so that it acquires creds at context creation.  After running this way I found svcgssd opens a file to the kerberos replay cache for every context/cred, eventually reaching ulimit.  For a busy cluster with many different client-user pairs that becomes a problem.  I am lost in the gss_krb5 code, but suspect that the kerberos code leaks credentials in this configuration.
> 
> Ondrej Palkovsky submitted a patch to specify multiple identities and acquire creds up-front using multiples of "-h": http://marc.info/?l=linux-nfsv4&m=123685185324902&w=2
> 
> I've updated that work to be current to nfs-utils-1.2.3 which solves our immediate problem, and it works well
Please go a head are repost the updated patch... Also it good if there was a man page 
updated was well...

tia,

steved.
