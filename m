Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod6og109.obsmtp.com ([64.18.1.23]:48512 "HELO
	exprod6og109.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751984Ab0IOGfq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Sep 2010 02:35:46 -0400
Content-Type: text/plain;
	charset="us-ascii"
Subject: RE: NFS : filehandle to filename mappings.
Date: Wed, 15 Sep 2010 02:35:43 -0400
Message-ID: <D3F292ADF945FB49B35E96C94C2061B90D35BB4D@nsmail.netscout.com>
In-Reply-To: <0D214280-7942-470B-B736-5299619A41E3@oracle.com>
References: <D3F292ADF945FB49B35E96C94C2061B90D35B46C@nsmail.netscout.com> <0D214280-7942-470B-B736-5299619A41E3@oracle.com>
From: "Tayade, Nilesh" <Nilesh.Tayade@netscout.com>
To: "Chuck Lever" <chuck.lever@oracle.com>, <linux-nfs@vger.kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

> -----Original Message-----
> From: Chuck Lever [mailto:chuck.lever@oracle.com]
> Sent: Tuesday, September 14, 2010 8:50 PM
> To: Tayade, Nilesh
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: NFS : filehandle to filename mappings.
> 
> 
> On Sep 14, 2010, at 8:10 AM, Tayade, Nilesh wrote:
> 

> >
> > Could someone please provide some information on how it gets the
> file
> > name in some of the packets (i.e. related to LOOKUP, WRITE etc.)?
> Does
> > it refer the lookup table at NFS server side and fills-in the name
> in
> > response?
> 
> Some NFS operations include a filename.  LOOKUP includes a filename
> because it is the premier way to convert a filename + directory to a
> file handle.  By and large, though, the NFS protocol deals in file
> handles, so that's what you will see in most NFS wire operations.
> 
> If you want to see the filename associated with a file handle,
> you'll need to manage a table of mappings based on what has gone by
> on the wire.  This is, for example, what wireshark does for it's NFS
> protocol display.  NFS clients cache this information as well.

Thanks for the response. So filename-filehandle mapping extraction seems
implementation dependent.

> 
> I recommend Brent Callaghan's seminal reference "NFS Illustrated"
> for a full overview of NFS operation.
> 
> 
> http://www.pearsonhighered.com/educator/academic/product/0,,02013257
> 05,00%2Ben-USS_01DBC.html?type=ABI

Thanks. I shall take a look.

> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 

