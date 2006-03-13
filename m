From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [NFS] [PATCH 000 of 14] knfsd: Introduction
Date: Mon, 13 Mar 2006 06:41:50 -0500
Message-ID: <44155A7E.4030804@RedHat.com>
References: <20060309174755.24381.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932130AbWCMLmu@vger.kernel.org>
To: NeilBrown <neilb@suse.de>
In-Reply-To: <20060309174755.24381.patches@notabene>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

NeilBrown wrote:
> The following series of patches changes the code for lookup up
> authentication/authorisation caches in sunrpc as used by nfsd.  That
> than having a delightful macro that defines a function of a particular
> type of cache, the functions are coded on a more traditional manner
> using library routines.
> 
> This will hopefully make the code more maintainable.
After looking over these patches, it appears there two 'minor'
things missing... comments and dprintk statements... :-)
Maybe I missed them, but out of all these 14 patches (i.e. basically
rewriting a critical part of kNFSD) not one comment or dprintk
as added....

Now I'm sure this is a much better design that the previous one,
(i.e. hide sight is always 20/20) and I'm looking forward to
help iron out the nits... But without meaningful comments and a way
to turn on a _few_ well placed "I failed here" type of debug
messages, the design really doesn't matter since the maintainable
has not improved... imho...

Secondly,  In a number of places, mostly in the alloc routines and in
patch 006 there are if statements like:

+	if (ch)
+		return container_of(ch, struct svc_export, h);
+	else
+		return NULL;
the else is simply not needed... Plus adding a dprintk like:

+	if (ch)
+		return container_of(ch, struct svc_export, h);
+	
+	dprintk("svc_export_update: returns NULL\n");
+	return NULL;
might make sense... assuming svc_export_update does not return NULL
99% of the time...

steved.
