From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: nfsdv4 leaks file descriptors
Date: Thu, 14 Apr 2011 15:10:06 -0400
Message-ID: <20110414191005.GB1721@fieldses.org>
References: <20110412140148.GA17242@gheift>
 <20110413211211.GA25189@fieldses.org>
 <20110414054844.GF17242@gheift>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Gerhard Heift <ml-nfs-linux-20110412-ef47-UG2eIutGyHWzQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44606 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932707Ab1DNTKH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Apr 2011 15:10:07 -0400
In-Reply-To: <20110414054844.GF17242@gheift>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 14, 2011 at 07:48:45AM +0200, Gerhard Heift wrote:
> On Wed, Apr 13, 2011 at 05:12:11PM -0400, J. Bruce Fields wrote:
> > On Tue, Apr 12, 2011 at 04:01:50PM +0200, Gerhard Heift wrote:
> > > Hello,
> > > 
> > > I have a linux kernel (2.6.38.2, armv5tel) running which exports a
> > > directory with following options:
> > 
> > Should be fixed in more recent stable kernel; let me know if not.
> 
> An even more recent stable than 2.6.38.2? I just compiled 2.6.39-rc3 and
> there the leak happens too.

Ugh.  OK, investigating.

--b.

> 
> > --b.
> 
> Regards,
>   Gerhard
> 
> > > /data ip/32(rw,async,crossmnt,insecure,root_squash,no_subtree_check,fsid=0)
> > > 
> > > On the client (Debian unstable, kernel 2.6.38-2-amd64) I mounted the
> > > directory under /media(nfs4import with
> > > 
> > > # mount -t nfs4 ip:/ /media/nfs4import
> > > 
> > > After a lot running fdupes on this folder the server kernel starts
> > > throwing messages like this one:
> > > 
> > >   VFS: file-max limit [number] reached
> > > 
> > > After a reboot I recognised that the number of used file descriptors
> > > increases during the run of fdupes (see /proc/sys/fs/file-nr). Even
> > > after unmounting the exported filesystem on the client, unexport the
> > > file system on the server and stopping the nfs-server the file
> > > descriptors are still allocated and unmounting the filesystem is not
> > > possible.
> > > 
> > > After a little bit of research I could create a small program, which
> > > increases the used file descriptors by one.
> > > 
> > > Regards,
> > >   Gerhard
> > 
> > > #include <stdio.h>
> > > 
> > > #define DIR "/media/nfs4import/"
> > > 
> > > int main(void) {
> > > 	FILE *f1;
> > > 	FILE *f2;
> > > 	char b[1024];
> > > 	int i;
> > > 
> > > 	// create file1
> > > 	f1 = fopen(DIR "file1.txt", "w");
> > > 	fwrite("test\n", 5, 1, f1);
> > > 	close(f1);
> > > 
> > > 	// open file1 in read mode
> > > 	f1 = fopen(DIR "file1.txt", "r");
> > > 
> > > 	for (i = 0; i < 1; i++) {
> > > 		// open file2 in write mode and close it
> > > 		f2 = fopen(DIR "file2.txt", "w");
> > > 		fclose(f2);
> > > 	
> > > 		// open file2 in read mode and close it
> > > 		// this causes the leak of a file descriptor on the server
> > > 		// just watch /proc/sys/fs/file-nr on the server
> > > 		f2 = fopen(DIR "file2.txt", "r");
> > > 		fclose(f2);
> > > 	}
> > > 	fclose(f1);
> > > 
> > > 	return 0;
> > > }
> > 
> > 
> > 
