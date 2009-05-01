Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:45373 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750869AbZEAQje (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 1 May 2009 12:39:34 -0400
In-Reply-To: <1241126587.15476.62.camel@heimdal.trondhjem.org>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>	 <5ECD2205-4DC9-41F1-AC5C-ADFA984745D3@oracle.com>
	 <49FA0CE8.9090706@redhat.com> <1241126587.15476.62.camel@heimdal.trondhjem.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org,
        linux-nfs-owner@vger.kernel.org, Peter Staubach <staubach@redhat.com>
Subject: Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page flushing
From: Brian R Cowan <brcowan@us.ibm.com>
Message-ID: <OFA2346ADE.C9BEB0D3-ON852575A9.00520371-852575A9.005B82BB@us.ibm.com>
Date: Fri, 1 May 2009 12:39:32 -0400
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

linux-nfs-owner@vger.kernel.org wrote on 04/30/2009 05:23:07 PM:

> As usual, the optimisation is workload dependent. The main type of
> workload we're targetting with this patch is the app that opens a file,
> writes < 4k and then closes the file. For that case, it's a no-brainer
> that you don't need to split a single stable write into an unstable + a
> commit.

The app impacted most is the gcc linker... I tested by building Samba, 
then by linking smbd. We think the linker memory maps the output file. 
Don't really know for sure since I don't know the gcc source any more than 
I'm an expert in the Linux NFS implementation. In any event, the linker is 
doing all kinds of lseeks and writes as it builds the output executable 
based on the various .o files being linked in. All of those writes are 
slowed down by this write change. If we were closing the file afterwards, 
that would be one thing, but we're not...

> 
> So if the application isn't doing the above type of short write followed
> by close, then exactly what is causing a flush to disk in the first
> place? Ordinarily, the client will try to cache writes until the cows
> come home (or until the VM tells it to reclaim memory - whichever comes
> first)...

We suspect it's the latter (something telling the system to flush memory) 
but chasing that looks to be a challenge...

> 
> Cheers
>   Trond
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html




=================================================================
Brian Cowan
Advisory Software Engineer
ClearCase Customer Advocacy Group (CAG)
Rational Software
IBM Software Group
81 Hartwell Ave
Lexington, MA
 
Phone: 1.781.372.3580
Web: http://www.ibm.com/software/rational/support/
 

Please be sure to update your PMR using ESR at 
http://www-306.ibm.com/software/support/probsub.html or cc all 
correspondence to sw_support@us.ibm.com to be sure your PMR is updated in 
case I am not available.

