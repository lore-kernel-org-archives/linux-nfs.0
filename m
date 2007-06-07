From: "Robert Rappaport" <robert.rappaport@gmail.com>
Subject: Re: [NFS] [PATCH] locks: provide a file lease method enabling cluster-coherent leases
Date: Thu, 7 Jun 2007 10:43:51 -0400
Message-ID: <f0a71180706070743h4f20f091nf6aa3a7edb95af0c@mail.gmail.com>
References: <OFB9D089FA.C0E6BE5A-ON882572F1.007D3720-882572F1.007E299C@us.ibm.com>
	 <1181086828.6108.11.camel@heimdal.trondhjem.org>
	 <f0a71180706061143t1b4a4374qef319deac727815f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "Marc Eshel" <eshel@almaden.ibm.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net,
	"David Teigland" <teigland@redhat.com>
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <f0a71180706061143t1b4a4374qef319deac727815f@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

My interpretation of the preceeding is  that there is agreement that
the functionality currently implemented in __setlease() should be
exported, even though the exported name may not be __setlease().  Is
this correct?

If so, that is just fine with me.

The question that I have now is when do you think it likely that these
changes get into the released code?  I hope that the plan is to get it
there fairly soon.

- Robert Rappaport

P.S. I previously intended to send to this thread a request to export
the __setlease() routine and also the above query.  However I
inadvertently forgot to send the messages in plain text and so it did
not appear in the thread, however some of you may have received the
messages.  Sorry, if this is redundant.


>
> On 6/5/07, Trond Myklebust <trond.myklebust@fys.uio.no> wrote:
> > On Tue, 2007-06-05 at 15:56 -0700, Marc Eshel wrote:
> > > Hi Bruce,
> > > The file system does need to keep the local state up to date, like it
> does
> > > with posix locks, so it might need to call __setlease(). The why we had
> it
> > > before was that the call to the file system was done from outside of
> > > setlease() and the file system was able to call setlease() which is
> > > exported. Now that the call to the fs  moved into setlease() the file
> > > system can not call it anymore so one possible solution would be to
> export
> > > __setlease().
> > > Marc.
> >
> > Please just make a vfs_setlease() which has the ability to call down
> > into the filesystem and leave the exported setlease() as a generic
> > method that can continue to be called by the filesystems themselves (and
> > acts as a fallback for vfs_setlease()). That would be closer to the VFS
> > naming conventions.
> >
> > Trond
> >
> >
>
>
