Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f48.google.com ([209.85.192.48]:34064 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752842AbbC0OHw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Mar 2015 10:07:52 -0400
Received: by qgep97 with SMTP id p97so134145194qge.1
        for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2015 07:07:51 -0700 (PDT)
Date: Fri, 27 Mar 2015 10:07:48 -0400
From: Jeff Layton <jeff.layton@primarydata.com>
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
Cc: linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: pNFS layout, ROC and multiple opens
Message-ID: <20150327100748.1bf881c3@tlielax.poochiereds.net>
In-Reply-To: <61504045.542929.1427455454361.JavaMail.zimbra@desy.de>
References: <61504045.542929.1427455454361.JavaMail.zimbra@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 27 Mar 2015 12:24:14 +0100 (CET)
"Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de> wrote:

> 
> 
> Hi folks,
> 
> we run into following issue:
> 
> on a client host we have two processes - A and B.
> Process A opens a file and reads some data:
> 
> OPEN -> LAYOUTGET -> READ.
> Notice, that layout has a roc set to true.
> 
> Process B opens the same file:
> 
> OPEN -> READ.
> 
> Client obviously re-used layout information.
> Now, process A closes the file and as a result,
> layout becomes invalid. Nevertheless, process B
> still assumes that layout still valid:
> 

So what happened at the CLOSE here? Was there an OPEN_DOWNGRADE or
something, or do these processes represent different openowners?

My understanding is that layouts with ROC flag set are valid until the
_last_ close and until any delegations are returned. The spec says
this, which is somewhat vague, but seems to imply that that
interpretation is correct:

     "A client may also hold a layout across multiple OPENs."

With the pnfs server we were playing with internally, we had an object
that tracked layouts on a per-file+per-client basis. Each open and
delegation held a reference to this object and when the last reference
was put, we returned the layout to the fs.

> I thinks this is the source of the problem:
> 
> fs/nfs/pnfs.c:
> 
> 1074         list_for_each_entry(ctx, &nfsi->open_files, list) {
> 1075                 state = ctx->state;
> 1076                 /* Don't return layout if there is open file state */
> 1077                 if (state != NULL && state->state != 0)
> 1078                         goto out_noroc;
> 1079         }
> 1080 
> 
> 
> this is with 3.19. The RHEL7 kernel send yet another LAYOUTGET when the process A
> closes the file.
> 

That seems like correct behavior to me. I don't think the server should
invalidate the layout in this situation.

That said, we probably need to have some clarification on the ROC flag
in the spec, or we end up with clients and servers potentially
disagreeing about when a layout is returned to the fs.


-- 
Jeff Layton <jeff.layton@primarydata.com>
