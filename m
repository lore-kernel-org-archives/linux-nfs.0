Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:25050 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755495Ab3KVTJl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Nov 2013 14:09:41 -0500
Subject: Re: [PATCH Version 2 0/3] GSSD: Use gss-ctx keys and gsskeyd to
 sync Kerberos credentials and kernel gss_contexts.
From: Simo Sorce <simo@redhat.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
Cc: "<steved@redhat.com>" <steved@redhat.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
In-Reply-To: <7841DFC0-4F05-42CB-AD84-0A3324588EC1@netapp.com>
References: <1382451757-3032-1-git-send-email-andros@netapp.com>
	 <1382454148.9794.72.camel@willson.li.ssimo.org>
	 <A8A66580-CD6F-4141-AE93-B1DD025BFD7A@netapp.com>
	 <1382458162.9794.85.camel@willson.li.ssimo.org>
	 <9C15298B-8915-46E2-85E1-5098F1A12832@netapp.com>
	 <1382462720.9794.131.camel@willson.li.ssimo.org>
	 <096F13FC-A99E-4C19-ACCA-01C244D7420F@netapp.com>
	 <1384980587.17044.49.camel@willson.li.ssimo.org>
	 <7841DFC0-4F05-42CB-AD84-0A3324588EC1@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 22 Nov 2013 14:09:39 -0500
Message-ID: <1385147379.3912.66.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2013-11-20 at 21:21 +0000, Adamson, Andy wrote:

> > Why do you need to abuse the keyring interface to implement a syscall ?
> 
> Do you think this job requires a system call? 
> 
> I felt the keyring interface gives us what we want: a way to pass some
> information and trigger a behavior.  The gss-ctx key caches the
> relationship between the principals Kerberos credentials and the
> associated RPC layer gss_cred (which in turn has the gss_context).
> When a gss-ctx key exists, the principal associated with the UID has
> kerberos credentials (located in the Kerberos ccache stored in the
> key) that are used for NFS, and the key serial is stored in the
> gss_cred.
> 
> From kernel documentation: Documentation/security/keys.txt
> 
> "This service allows cryptographic keys, authentication tokens, cross-domain
> user mappings, and similar to be cached in the kernel for the use of
> filesystems and other kernel services."
> 
> I think the gss-ctx key fits into the above description (under
> "similar"), so  I don't think of this use as an abuse.

You walk a fine line here.

IMHO the kernel keyring is a place where you store information. It is
true that based on the information you store there you can take
additional actions (in the user space usually). But I think that the
gss-ctx usage is overstepping the  boundary and using the presence of a
key as a trigger to perform actions in the kernel. This is something
that is traditionally done via a syscall.

My main concern is around things like access control, how is that
performed ?

Also I think it introduces a lot more code than is needed for the
simplest implementation.
The simplest implementation in my mind is that the login system can call
the syscall no matter what the current status in the kernel and ask the
nfs client subsystem to nuke any credentials associated to uid 1234
whether that uid has any credentials on the system or not. So it allows
to ignore completely any real tracking and just simply be sure each and
all creds associated to that user id are nuked.
this could actually be extended beyond NFS, ideally any kernel driver
that stores some form of credential or data associated to a specific UID
may hook to the syscall to be notified when it is time to blast away the
data.

Your model seem more fragile in the sense that you need to set up the
whole tracking part to, so if you have a bug there you'll end up not
removing creds from the kernel. It is also very specific to the NFS
client, but that may or may not be an issue.

> > Or did I misunderstand what you mean by "telling the kernel to do X" ?
> > 
> >>> This way you can replace the logic of how to keep track of what is
> >>> going on completely in user space, where it can easily be adjusted
> >>> and adapted  as experience is gained.
> >>> 
> >>> IE: track it completely in userspace for now and only provide a
> >>> syscall to kill creds per UID, no tracking on the kernel side.
> >> 
> >> Yes - I believe that is what the gss-ctx keyring code I wrote does.
> > 
> > A keyring is not a syscall.
> 
> Yes, but it does as you suggested "provide a downcall to the kernel that will tell it: destroy any
> cache for 'uid number"
> 
> What is the disadvantage of using the keyring?

Hopefully I answered above.

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

