Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e8.ny.us.ibm.com ([32.97.182.138]:41796 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752065Ab3J2E1Z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Oct 2013 00:27:25 -0400
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <eshel@us.ibm.com>;
	Tue, 29 Oct 2013 00:27:24 -0400
In-Reply-To: <875BFA1C-0305-49FF-85ED-7B156666AE85@netapp.com>
References: <20131028180838.GG31322@fieldses.org> <526EC3F7.3090601@gmail.com> <526EFFCC.2060506@redhat.com> <18F0636D-7CE0-42C1-9249-325DF69516D4@netapp.com> <526F0893.5030700@redhat.com> <A7C1B206-12CD-4958-9528-A8D9C9847011@netapp.com> <1383010758.8774.97.camel@heisenberg.scientia.net> <875BFA1C-0305-49FF-85ED-7B156666AE85@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Anand Avati <aavati@redhat.com>,
        Christoph Anton Mitterer <calestyo@scientia.net>,
        Mailing List Linux NFS <linux-nfs@vger.kernel.org>,
        linux-nfs-owner@vger.kernel.org, nfsv4@ietf.org
MIME-Version: 1.0
Subject: Re: XATTRs in NFS?
From: Marc Eshel <eshel@us.ibm.com>
Message-ID: <OFBDEFE8C0.ABF00267-ON88257C13.0014E881-88257C13.00187994@us.ibm.com>
Date: Mon, 28 Oct 2013 21:27:19 -0700
Content-Type: text/plain; charset="US-ASCII"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,
I am just trying to see if there any path here to get xattr over NFS.

Assuming that there is agreement that xattr are used and needed, and we 
need to build a better case here but just give alternative solutions 
doesn't mean that is not needed, almost every thing can be done with an 
additional DB that associates attributes with files but it is not the best 
or right way.

So if we had an NFS protocol extension (might not be named attributes) 
that mapped  to and was semantically compatibly to Linux xattr, as Nico 
wrote, would that be enough to consider adding it to the Linux NFS?

I see the need to show requirement and better interface over the NFS 
protocol (with no security holes)  but not sure if we have another problem 
with standardizing xattr in Linux?

Thanks, Marc. 



From:   "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To:     Christoph Anton Mitterer <calestyo@scientia.net>, 
Cc:     Wheeler Ric <rwheeler@redhat.com>, Anand Avati 
<aavati@redhat.com>, "Dr Fields James Bruce" <bfields@redhat.com>, Mailing 
List Linux NFS <linux-nfs@vger.kernel.org>, Dickson Steve 
<steved@redhat.com>
Date:   10/28/2013 07:28 PM
Subject:        Re: XATTRs in NFS?
Sent by:        linux-nfs-owner@vger.kernel.org




On Oct 28, 2013, at 9:39 PM, Christoph Anton Mitterer 
<calestyo@scientia.net> wrote:

> Trond,... since you ask for motivations pro NFS-XATTRs, I wondered what
> are the strong reasons against?

As I've already told you: you're asking for the addition of a feature 
which is inadequately defined, and is not documented in any standard.

> Of course someone has to do the work,... but that's not really and
> argument pro or con NFS-XATTRs, is it?
> 
> The security problems with namespaces like trusted. or so can probably
> be solved quite easy, e.g. simply by not supporting or
> ignoring/rejecting them.
> 
> You've mentioned caching issues,... could you elaborate a bit on that?
> How is that much different from caching any other file metadata NFS
> transfers?

The standard metadata such as ctime, mtime, size, .... are all part of an 
existing NFS caching model called close-to-open. We know how they change 
when the filesystem data changes.

How do I know when it is safe to cache your checksum xattr? I don't even 
know what it is, let alone what its relation is to the other filesystem 
objects.
Let's say client B modifies the file and updates the checksum. When client 
A opens the file, it will see that the data has changed, but how does it 
know that it also needs to update the xattr information?
Alternatively, let's say that client A reads the file and checksum data 
after client B has updated the file, but before it updates the checksum. 
What will cause client A to stop caching the stale checksum once client B 
has updated it?

Trond--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html



