From: David Howells <dhowells@redhat.com>
Subject: cat and grep can cause excess page read at EOF
Date: Thu, 30 Apr 2009 15:25:28 +0100
Message-ID: <304.1241101528@redhat.com>
Cc: dhowells@redhat.com
To: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi,

When reading a file that ends exactly on a page boundary, reading an entire
file and relying on read() = 0 to indicate the EOF (such as is done by cat and
grep) causes readpage() to be invoked on the filesystem for a page immediately
beyond EOF.

Is it worth making generic_file_aio_read() note that the EOF has been reached
and return 0 immediately, rather than trying to read over the EOF?  The
problem with doing that might be that filesystems such as NFS2/3 might
occasionally miss the fact that a file has been extended on the server.

The call chain I see on my testbox is this:

 [<ffffffffa0348382>] ? nfs_readpage+0x138/0x16a [nfs]
 [<ffffffff8026fa15>] ? generic_file_aio_read+0x399/0x55a
 [<ffffffff80294199>] ? do_sync_read+0xce/0x113
 [<ffffffff80243cb8>] ? autoremove_wake_function+0x0/0x2e
 [<ffffffff80355fe5>] ? file_has_perm+0x82/0x8b
 [<ffffffff80294cd1>] ? vfs_read+0xaa/0x153
 [<ffffffff80294e36>] ? sys_read+0x45/0x6e
 [<ffffffff8020adeb>] ? system_call_fastpath+0x16/0x1b

nfs_readpage() is asked to read page 0x6400 from a 100MB file - which doesn't
exist, and so calls nfs_return_empty_page().

David
