Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:60798 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751346AbdK3USX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 30 Nov 2017 15:18:23 -0500
Date: Thu, 30 Nov 2017 15:18:23 -0500
To: Olga Kornievskaia <aglo@umich.edu>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Olga Kornievskaia <kolga@netapp.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v6 00/10] NFSD support for asynchronous COPY
Message-ID: <20171130201823.GE3923@fieldses.org>
References: <20171024174752.74910-1-kolga@netapp.com>
 <CAN-5tyHmrfKTfC8ELHA7RpHmUaVzBRKBqQNTpOYnu3SM7OdCnQ@mail.gmail.com>
 <CAN-5tyHumx9s7nkweA1B4CniPD_NzeGyd9d9FNL5ZxzX6KQ+zw@mail.gmail.com>
 <20171114004804.GB14185@parsley.fieldses.org>
 <CAN-5tyH2tEFsbVxhSdQqu8DW_7Zs4eHse4HWEN=vNAgKLiNSDQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyH2tEFsbVxhSdQqu8DW_7Zs4eHse4HWEN=vNAgKLiNSDQ@mail.gmail.com>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 28, 2017 at 03:28:46PM -0500, Olga Kornievskaia wrote:
> On Mon, Nov 13, 2017 at 7:48 PM, J. Bruce Fields <bfields@redhat.com> wrote:
> > On Fri, Nov 10, 2017 at 10:01:02AM -0500, Olga Kornievskaia wrote:
> >> On Fri, Nov 3, 2017 at 3:57 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> >> > Bruce, any comments on this version?
> >>
> >> Bruce, do you have any comments on this version?
> >
> > I don't yet, apologies.  It is on my list to look at.
> >
> 
> Any ideas as to when that would be?

Sorry for the silence.  I'll try to get it reviewed in time for 4.16.

But I'm worrying about async behavior.  Just the usual complaint:

	- A large copy could take anywhere from milliseconds to hours.

	- The only way the protocol gives to measure progress is
	  OFFLOAD_STATUS, but I'm pessimistic that we'll get a
	  corresponding copy_progress syscall interface that
	  applications will get patched to use.

So, currently the server's trying to avoid the problem by returning
short COPY results and hoping applications will handle that gracefully
(and that readahead and write behind will save performance).

But I guess that won't work in the server-to-server case.  Or would it?
I *think* you can just send one NOTIFY and then reuse the same stateid
in multiple COPYs, so maybe it's not any worse than in the single-server
case.

That would be a lot simpler if it worked.

--b.
