Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58530 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754999AbaKEQcb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2014 11:32:31 -0500
Message-ID: <545A510C.4000208@RedHat.com>
Date: Wed, 05 Nov 2014 11:32:12 -0500
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Chris Siebenmann <cks@cs.toronto.edu>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: Best approach for authenticating hosts for NFS (v3)?
References: <20141104165313.CA9025A04C1@testapps.cs.toronto.edu>
In-Reply-To: <20141104165313.CA9025A04C1@testapps.cs.toronto.edu>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 11/04/2014 11:53 AM, Chris Siebenmann wrote:
> PS: 'switch to NFS v4 to strongly authenticate user requests' is not an
>     option for us. We specifically value things that cannot be done
>     with true verification of user identification, like cron, and we
>     don't have and don't want to build the infrastructure that would
>     be required for strongly authenticated NFS v4.
The exact same "strongly authenticate" that in v4 is available
with v3. NFS secure mounts (-o krb5) are available 
with all NFS protocol versions.

Tying NFS secure mounts with an FreeIPA environment should work
out well..    

steved.
 
