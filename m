Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:57235 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932465Ab2AKHoV convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Jan 2012 02:44:21 -0500
MIME-Version: 1.0
In-Reply-To: <20120109192517.GB16973@fieldses.org>
References: <4EF6A6CA.1020606@tonian.com> <4F0AE25C.5020706@panasas.com> <20120109192517.GB16973@fieldses.org>
From: Benny Halevy <bhalevy@tonian.com>
Date: Wed, 11 Jan 2012 09:44:00 +0200
Message-ID: <CAEMWVhvaNOENPC2jRMB7zuP4ScsNmp5BMfXYmnFL71_N-4D0Rw@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] [ATTEND] linux-pnfs server implementations
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Boaz Harrosh <bharrosh@panasas.com>, lsf-pc@lists.linux-foundation.org,
        linux-fsdevel@vger.kernel.org, NFS list <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 9, 2012 at 9:25 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Mon, Jan 09, 2012 at 02:49:32PM +0200, Boaz Harrosh wrote:
>> On 12/25/2011 06:30 AM, Benny Halevy wrote:
>> > Now that the client side of pnfs is in the mainline kernel
>> > I believe it is time to consider the inclusion of the server side.
>
> We're also closing in on the basic 4.1 todo's, so I agree that it will
> soon be time to talk about merging server-side pNFS.
>
>> > I propose the following agenda for discussion
>> > (order may change with no advance notice :)
>> >
>> > * What's currently available in git://linux-nfs.org/~halevy/linux-pnfs.git
>> >   - What are the sub-projects
>> >   - How they relate to each other
>> >
>> > * High-level design of the implementation
>> >
>> > * Summary of generic changes in nfsd
>> >
>> > * For each of the different sub-projects, briefly present:
>> >   - What does it do
>> >   - Benefits and Potential
>> >   - Limitations
>> >   - Status
>> >   - To-do
>> >
>> > * Prerequisites for inclusion
>
> Understood that it may depend on where things stand in April, but: what
> specifically do you think will be likely to require the attention of a
> wider group of linux filesystem developers (ass opposed to just nfs
> developers)?

I have nothing specific at this time. My thinking was to present the
what's and why's
of the prerequisites in high level and maybe provide an example.

Benny

>
> --b.
>
>> > * Discussion
>> >
>>
>> Me too! This subject is close to my heart, as exofs is the most
>> complete and advanced pNFSD base implementation. Last testing
>> has demonstrated amazing performance and scalability. Saturating
>> 10G from a single client and saturating 4*10G storage cluster
>> from multiple clients.(Though there were problems with too many
>> clients)
