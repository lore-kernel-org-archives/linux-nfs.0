Return-Path: keyrings-bounces@linux-nfs.org
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20141114151818.20661.21735.stgit@warthog.procyon.org.uk>
References: <20141114151818.20661.21735.stgit@warthog.procyon.org.uk>
	<20141030174612.10093.61557.stgit@manet.1015granger.net>
MIME-Version: 1.0
Date: Fri, 14 Nov 2014 15:19:13 +0000
Message-ID: <20739.1415978353@warthog.procyon.org.uk>
Cc: neilb@suse.de, linux-nfs@vger.kernel.org, chuck.lever@oracle.com,
        keyrings@linux-nfs.org
Subject: Re: [Keyrings] [PATCH] KEYS: search_nested_keyrings() should honour
	NO_STATE_CHECK for the root
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/keyrings>,
	<mailto:keyrings-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/keyrings>
List-Post: <mailto:keyrings@linux-nfs.org>
List-Help: <mailto:keyrings-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/keyrings>,
	<mailto:keyrings-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: keyrings-bounces@linux-nfs.org
Errors-To: keyrings-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

David Howells <dhowells@redhat.com> wrote:

> search_nested_keyrings() should probably honour KEYRING_SEARCH_NO_STATE_CHECK
> when checking the keyring at the root of its search by not setting
> DO_STATE_CHECK if NO_STATE_CHECK is set.
> 
> For the moment, this doesn't really matter as NO_STATE_CHECK is only used for
> cycle detection and possession determination, neither of which use
> keyring_search_iterator() as the search iterator check function, so
> DO_STATE_CHECK is actually ignored there.

Ignore this - I forgot to update the description.
_______________________________________________
Keyrings mailing list
Keyrings@linux-nfs.org
To change your subscription to this list, please see http://linux-nfs.org/cgi-bin/mailman/listinfo/keyrings
