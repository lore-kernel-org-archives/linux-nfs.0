From: James Morris <jmorris@namei.org>
Subject: Re: VFS and IMA API patch series please pull
Date: Thu, 10 Dec 2009 09:38:03 +1100 (EST)
Message-ID: <alpine.LRH.2.00.0912100937110.18606@tundra.namei.org>
References: <1260393952.3344.18.camel@localhost>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-cachefs@redhat.com, ecryptfs-devel@lists.launchpad.net,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-arch@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org,
        linux-security-module@vger.kernel.org, rdunlap@xenotime.net,
        Mimi Zohar <zohar@linux.vnet.ibm.com>,
        "Serge E. Hallyn" <serue@us.ibm.com>,
        David Howells <dhowells@redhat.com>, steved@redhat.com, tiwai@suse.de,
        viro@zeniv.linux.org.uk, tyhicks@linux.vnet.ibm.com,
        kirkland@canonical.com, Andrew Morton <akpm@linux-foundation.org>,
        npiggin@suse.de, wli@holomorphy.com, mel@csn.ul.ie, shuber2@gmail.com,
        dsmith@redhat.com, jack@suse.cz, jmalicki@metacarta.com, hch@lst.de,
        "J. Bruce Fields" <bfields@fieldses.org>, neilb@suse.de,
        agruen@suse.de, j
To: Eric Paris <eparis@redhat.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1260393952.3344.18.camel@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 9 Dec 2009, Eric Paris wrote:

> I'm not sure who the best person to pull this would be.  VFS maintainer?
> Al?  Should I just send straight to Linus?  I'm not sure what the best
> path is.  All of the individual fs changes have been acked by their
> respective maintainers and the IMA work has been acked by the IMA
> maintainer.  The only patches without CLEAR acks and review are the two
> which remove the get_empty_filp() and init_file() calls.

It should probably go via Al, due to all the VFS core changes, but I can 
take it in my tree if needed.

-- 
James Morris
<jmorris@namei.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
