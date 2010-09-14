Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:18884 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751746Ab0INPUw convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Sep 2010 11:20:52 -0400
Subject: Re: NFS : filehandle to filename mappings.
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <D3F292ADF945FB49B35E96C94C2061B90D35B46C@nsmail.netscout.com>
Date: Tue, 14 Sep 2010 11:19:39 -0400
Cc: <linux-nfs@vger.kernel.org>
Message-Id: <0D214280-7942-470B-B736-5299619A41E3@oracle.com>
References: <D3F292ADF945FB49B35E96C94C2061B90D35B46C@nsmail.netscout.com>
To: "Tayade, Nilesh" <Nilesh.Tayade@netscout.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Sep 14, 2010, at 8:10 AM, Tayade, Nilesh wrote:

> Hi,
> 
> Sorry, the question might sound repeated; but I am looking for some
> other details here. 
> I looked at the NFS protocol packets. I could see that in case of
> file/directory operations(e.g. vi a file) some of the NFS packets (e.g.
> GETATTR procedure) show just the filehandle. But later when the LOOKUP
> is executed the corresponding NFS packet shows the filename (I observed
> in case of regular file).
> 
> Could someone please provide some information on how it gets the file
> name in some of the packets (i.e. related to LOOKUP, WRITE etc.)? Does
> it refer the lookup table at NFS server side and fills-in the name in
> response?

Some NFS operations include a filename.  LOOKUP includes a filename because it is the premier way to convert a filename + directory to a file handle.  By and large, though, the NFS protocol deals in file handles, so that's what you will see in most NFS wire operations.

If you want to see the filename associated with a file handle, you'll need to manage a table of mappings based on what has gone by on the wire.  This is, for example, what wireshark does for it's NFS protocol display.  NFS clients cache this information as well.

I recommend Brent Callaghan's seminal reference "NFS Illustrated" for a full overview of NFS operation.

  http://www.pearsonhighered.com/educator/academic/product/0,,0201325705,00%2Ben-USS_01DBC.html?type=ABI

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



