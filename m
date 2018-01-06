Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:42040 "EHLO
        merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751377AbeAFWg4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Jan 2018 17:36:56 -0500
Subject: Re: [PATCH] Documentation: security/credentials.rst: explain need to
 sort group_list
To: Matthew Wilcox <willy@infradead.org>,
        Jonathan Corbet <corbet@lwn.net>
Cc: NeilBrown <neilb@suse.com>, linux-doc@vger.kernel.org,
        dhowells@redhat.com,
        Thiago Rafael Becker <thiago.becker@gmail.com>,
        viro@zeniv.linux.org.uk, schwidefsky@de.ibm.com,
        bfields@fieldses.org, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
References: <878te9os81.fsf@notabene.neil.brown.name>
 <20171211142708.GA23284@bombadil.infradead.org>
 <20171211151420.18655-1-thiago.becker@gmail.com>
 <20742.1514904840@warthog.procyon.org.uk>
 <87wp10dlgk.fsf@notabene.neil.brown.name>
 <20180102210431.GA20405@bombadil.infradead.org>
 <20180106110908.0adc1be2@lwn.net>
 <20180106202013.GA6183@bombadil.infradead.org>
From: Randy Dunlap <rdunlap@infradead.org>
Message-ID: <f99813d4-0fb4-686d-aad8-b383d9ebcce7@infradead.org>
Date: Sat, 6 Jan 2018 14:36:38 -0800
MIME-Version: 1.0
In-Reply-To: <20180106202013.GA6183@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 01/06/18 12:20, Matthew Wilcox wrote:
> 
> I've been thinking about all the kernel-doc we have that's completely
> unincorporated.  I've also been thinking about core-api/kernel-api.rst
> which to my mind is completely unreadable in its current form -- look at
> https://www.kernel.org/doc/html/latest/core-api/kernel-api.html and you
> wouldn't really know there's anything in it beyond the List Management
> Functions.

The index is on the left side, but would be better (duplicated?) at the beginning
of the chapter.  The left side is still useful for navigation, but then it
scrolls away too quickly when the right side text is scrolled.

> I think the right path forward is to have kernel-api.rst be the dumping
> ground for all the files with kernel-doc but nothing more.  That gives
> us somewhere to link to.

FWFW, I have recently done firewire.rst, infiniband.rst, and some additions
to scsi.rst.  But the new firewire.rst and infiniband.rst could use some
introductory material before just jumping into the API.


> Then we need little stories about how all the functions in a subsystem
> fit together.  For example, we can create a list.rst which explains how
> this is a doubly-linked list that you use by embedding a list_head into
> your data structure, and has O(1) insertion/deletion, etc, etc.  Then we
> would move all the list.h kernel-doc from kernel-api.rst into list.rst.


-- 
~Randy
