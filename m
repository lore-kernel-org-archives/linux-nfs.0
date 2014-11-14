Return-Path: keyrings-bounces@linux-nfs.org
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <10137.1415976586@warthog.procyon.org.uk>
Date: Fri, 14 Nov 2014 09:13:39 -0600
Message-Id: <83BF4397-2B0C-4A90-AC15-9152D8A9C1F1@oracle.com>
References: <20141030174612.10093.61557.stgit@manet.1015granger.net>
	<10137.1415976586@warthog.procyon.org.uk>
To: David Howells <dhowells@redhat.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, keyrings@linux-nfs.org
Subject: Re: [Keyrings] Are both DO_STATE_CHECK and NO_STATE_CHECK required?
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/keyrings>,
	<mailto:keyrings-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/keyrings>
List-Post: <mailto:keyrings@linux-nfs.org>
List-Help: <mailto:keyrings-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/keyrings>,
	<mailto:keyrings-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="windows-1252"
Sender: keyrings-bounces@linux-nfs.org
Errors-To: keyrings-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 14, 2014, at 8:49 AM, David Howells <dhowells@redhat.com> wrote:

> I'm wondering if I actually need KEYRING_SEARCH_DO_STATE_CHECK and
> KEYRING_SEARCH_NO_STATE_CHECK as separate flags rather than just states o=
f the
> same flag.
> =

> The most important distinction is in search_nested_keyrings() where I tur=
n on
> DO_STATE_CHECK specifically for potential matches on the root keyring.
> =

> However, NO_STATE_CHECK is only used for two special searches: possession
> determination and cycle detection.  Neither of these use
> keyring_search_iterator() as the iteration function, so neither actually =
takes
> any notice of DO_STATE_CHECK.
> =

> Everything else currently uses - or should use - DO_STATE_CHECK, including
> key_get_instantiation_authkey().

I replied earlier before reading all my mail. Thanks for posting
these, I=92ll give them a try early next week.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



_______________________________________________
Keyrings mailing list
Keyrings@linux-nfs.org
To change your subscription to this list, please see http://linux-nfs.org/c=
gi-bin/mailman/listinfo/keyrings
