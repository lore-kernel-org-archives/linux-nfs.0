From: Brian Kerr <kerrboy@gmail.com>
Subject: Re: NFS reliability in Enterprise Environment
Date: Thu, 2 Feb 2006 00:00:25 -0500
Message-ID: <b83c9e30602012100p3cdc75b2w3f6d3e128d51305d@mail.gmail.com>
References: <5573EF758F632B43A91FE1A01B6AC3D401B77D6B@exch3-dc-aus.northamerica.corporate-domain.net>
	 <b83c9e30602011608s6ba5b8d9sc2c9b01e27740ce0@mail.gmail.com>
	 <1138840427.26648.178.camel@seki.nac.uci.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F4Wa4-0002az-Co
	for nfs@lists.sourceforge.net; Wed, 01 Feb 2006 21:00:28 -0800
Received: from xproxy.gmail.com ([66.249.82.196])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1F4Wa3-0005qo-7N
	for nfs@lists.sourceforge.net; Wed, 01 Feb 2006 21:00:28 -0800
Received: by xproxy.gmail.com with SMTP id s6so217841wxc
        for <nfs@lists.sourceforge.net>; Wed, 01 Feb 2006 21:00:25 -0800 (PST)
To: nfs@lists.sourceforge.net
In-Reply-To: <1138840427.26648.178.camel@seki.nac.uci.edu>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On 2/1/06, Dan Stromberg <strombrg@dcs.nac.uci.edu> wrote:

> We tried GFS served out over NFS, and it didn't work out well at all.
>
> In fact, since we had a bunch of 2 terabyte slices that were made
> available via GFS, we could've just eliminated GFS altogether, because
> 32 bit linux can do that -without- GFS.  Sorry my GFS notes are a little
> sketchy, but my manager seemed to want to do the GFS stuff himself :)  I
> mostly just documented how to start it up and shut it down:

That's not what I wanted to hear!

We are looking at fairly dense storage and will need to make about
9-10 2TB partitions.  Having the limitation of only one host seeing a
partition is obviously a huge drawback.  I was hoping to avoid this
with clustered file systems of some sort.  I plan to do some of my own
testing on a smaller scale before moving anything into the next phase.

Thanks for the summary!

>         http://dcs.nac.uci.edu/~strombrg/gfs_procedures.html
>
>
> We later tried Lustre, but that didn't work out well in combination with
> NFS either, despite our having contracted with the vendor to -make- it
> work.  It was just iteration after iteration and patch after patch, and
> "it's the hardware" vs "it's the software" because we had so many
> vendors involved.  My lustre notes are far less sketchy, because I got
> to take a lead role in that one for the most part:
>
>         http://dcs.nac.uci.edu/~strombrg/Lustre-notes.html
>
> I also still have reams of log data that I shared with the vendor:
>
>         http://dcs.nac.uci.edu/~strombrg/lustre-info-for-CFS.html
>
> ...and as I skim through it, I'm recalling that I eventually discovered
> that we were getting errors even on the lustre NAS head that was serving
> data out over NFS - IE, with no NFS involved at all.  Then again, we
> were using a fork off the lustre mainline that wasn't to be merged back
> into the mainline (which means if we ever needed to upgrade, we'd
> probably end up contracting with them again to merge the needed changes
> into either the mainline, or -another- fork).
>
>
> We eventually got IBM to buy back the PC hardware they sold us for the
> storage farm, got a StorEdge 3511 and a sparc box from Sun, and we had
> about 16 terabytes up in short order.  We're using a sparc with Solaris
> on it as a NAS head for all that data, and then an AIX system accesses
> the data over NFS.
>
>
> QFS, the filesystem we're using on it, is actually kind of cool.  It
> allows you to easily aggregate data into one huge filesystem, and it
> merges the volume management and filesystem layers for performance - but
> I'm glad it's them maintaining the combination and not me :)
>
>
>


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
