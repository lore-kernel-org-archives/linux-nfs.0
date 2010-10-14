Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60063 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754594Ab0JNOFf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 14 Oct 2010 10:05:35 -0400
Date: Thu, 14 Oct 2010 10:05:34 -0400
To: "Tayade, Nilesh" <Nilesh.Tayade@netscout.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: 'Continuation' packets in case of NFS READ.
Message-ID: <20101014140534.GB24146@fieldses.org>
References: <D3F292ADF945FB49B35E96C94C2061B90DAD01D8@nsmail.netscout.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <D3F292ADF945FB49B35E96C94C2061B90DAD01D8@nsmail.netscout.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Oct 14, 2010 at 03:48:39AM -0400, Tayade, Nilesh wrote:
> Hi,
> 
> I am working on NFS packet capturing for NFS version3 protocol. In one
> of the scenarios, I tried opening a very big file and in this case the
> file data was transferred from server to client in several chunks.
> 
> I observed there were some 'Continuation' RPC payload sent from server
> to client which carry file data. But even in Wireshark this doesn't
> decode any other fields apart from the file contents.
> 
> Could someone please advice how client knows which particular file a
> specific 'continuation' packet belongs to? The packet doesn't even have
> the filehandle/program version data.
> 
> I have attached the trace file.

Without looking at the trace: usually, if it's a complete trace,
wireshark will first show you each individual tcp segment, just labelled
as something like "rpc continutation data", then it will show you at the
end a frame with the actual READ request, the fully assembled data, and
somewhere in the packet-details pane a list of the frame numbers from
which that was assembled.

So you'd want to look for that final frame with the READ reqeust, and
the filehandle on that READ, and then figure out which file that
filehandle was for.

--b.
