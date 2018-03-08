Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:43570 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752093AbeCHPHG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Mar 2018 10:07:06 -0500
Date: Thu, 8 Mar 2018 10:07:05 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v7 05/10] NFSD introduce asynch copy feature
Message-ID: <20180308150705.GA10782@fieldses.org>
References: <20180220164229.65404-1-kolga@netapp.com>
 <20180220164229.65404-6-kolga@netapp.com>
 <20180307210551.GC28844@fieldses.org>
 <CAN-5tyGBTSOeqiLxVoAE04VTF+--9UtGoxoNvHzAXH++c6vRCw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAN-5tyGBTSOeqiLxVoAE04VTF+--9UtGoxoNvHzAXH++c6vRCw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 07, 2018 at 05:06:21PM -0500, Olga Kornievskaia wrote:
> On Wed, Mar 7, 2018 at 4:05 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > I don't understand yet why you need these two cases.  Anyway, I'd rather
> > you did this in the caller.  So the caller can do either:
> >
> >         spin_lock()
> >         list_del()
> >         spin_unlock()
> >         cleanup_async_copy()
> >
> > or just
> >
> >         cleanup_async_copy()
> >
> > Or define another helper for the first case if you're really doing it a
> > lot.  Just don't make me have to remember what that second argument
> > means each time I see it used.
> 
> Ok I'll fix it. It was added after I changed where copy was added to
> the list. In one case, now I needed to do all of the cleanup but the
> copy wasn't added to the list yet.

As long as you've at least initialized the list, it's OK to call
list_del() on it.  So another alternative might just be to call
list_del() in both cases.

--b.
