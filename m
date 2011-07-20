Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.uvm.edu ([132.198.101.168]:50403 "EHLO smtp1.uvm.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751140Ab1GTM4y convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Jul 2011 08:56:54 -0400
Subject: Re: multiple service identities for svcgssd
Content-Type: text/plain; charset=us-ascii
From: Benjamin Coddington <bcodding@uvm.edu>
In-Reply-To: <20110713173534.GA11665@fieldses.org>
Date: Wed, 20 Jul 2011 08:56:47 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <960320AD-849D-45D7-B61F-859CDD957375@uvm.edu>
References: <3EA8A380-460C-4CDC-9591-7034D2E38D93@uvm.edu> <20110713173534.GA11665@fieldses.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Jul 13, 2011, at 1:35 PM, J. Bruce Fields wrote:
> On Wed, Jul 13, 2011 at 12:03:03PM -0400, Benjamin Coddington wrote:
>> I am working on a linux NFS cluster that requires a single svcgssd to establish contexts under multiple service names.
>> 
>> In this scenario, svcgssd can be called with "-n" so that it acquires creds at context creation.  After running this way I found svcgssd opens a file to the kerberos replay cache for every context/cred, eventually reaching ulimit.  For a busy cluster with many different client-user pairs that becomes a problem.  I am lost in the gss_krb5 code, but suspect that the kerberos code leaks credentials in this configuration.
>> 
>> Ondrej Palkovsky submitted a patch to specify multiple identities and acquire creds up-front using multiples of "-h": http://marc.info/?l=linux-nfsv4&m=123685185324902&w=2
>> 
>> I've updated that work to be current to nfs-utils-1.2.3 which solves our immediate problem, and it works well -- but running svcgssd with '-n' is still going to leak file handles to the replay cache.  What's the best way to fix this?  Can the created-on-the-fly cred can be re-used for subsequent contexts?
> 
> Sounds like a likely kerberos bug as well--may be use asking the
> kerberos folks?
> 
> --b.

It is a kerberos bug where the context is not cleaned up in gss_export_lucid_sec_context(), so svcgssd leaks a bit.  Here's a reference to the kerberos problem:  http://marc.info/?t=131068390400045&r=1&w=2

Thank you for the suggestion.

Ben