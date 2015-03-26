Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:45305 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752418AbbCZPiv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Mar 2015 11:38:51 -0400
Date: Thu, 26 Mar 2015 11:38:48 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, Marc Eshel <eshel@us.ibm.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-nfs-owner@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH v3 3/3] NFSD: Add support for encoding multiple segments
Message-ID: <20150326153848.GB30482@fieldses.org>
References: <OFB111A6D8.016B8BD5-ON88257E0D.001D174D-88257E0D.005268D6@us.ibm.com>
 <20150319153627.GA20852@fieldses.org>
 <OF38D4D18B.19055EC2-ON88257E0D.0059BA03-88257E0D.005A781F@us.ibm.com>
 <20150320151718.GD2036@fieldses.org>
 <20150320162303.GA18786@infradead.org>
 <20150320182621.GH2036@fieldses.org>
 <CAFX2JfkybBPcqD6A8r-jOkPnkL26=NEuK3zhA6TLn-DVam+kfQ@mail.gmail.com>
 <20150324174916.GA28906@infradead.org>
 <55142405.3090000@Netapp.com>
 <CAHQdGtTavsJ5k0taRCBi7CgP1NYjqQmgbQcE-yUkXQOKdQsGpA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtTavsJ5k0taRCBi7CgP1NYjqQmgbQcE-yUkXQOKdQsGpA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 26, 2015 at 11:32:25AM -0400, Trond Myklebust wrote:
> On Thu, Mar 26, 2015 at 11:21 AM, Anna Schumaker
> <Anna.Schumaker@netapp.com> wrote:
> > Here are my updated numbers!  I tested with files 5G in size: one 100% data, one 100% hole, and one alternating between hole and data every 4K.  I collected data for both v4.1 and v4.2 with and without the READ_PLUS patches:
> >
> > ##########################
> > #                        #
> > #   Without READ_PLUS    #
> > #                        #
> > ##########################
> >
> >
> > NFS v4.1:
> >                             Trial
> > |---------|---------|---------|---------|---------|---------|---------|
> > |         |    1    |    2    |    3    |    4    |    5    | Average |
> > |---------|---------|---------|---------|---------|---------|---------|
> > |    Data |  8.723s |  7.243s |  8.252s |  6.997s |  6.980s |  7.639s |
> > |    Hole |  5.271s |  5.224s |  5.060s |  4.897s |  5.321s |  5.155s |
> > |   Mixed |  8.050s | 10.057s |  7.919s |  8.060s |  9.557s |  8.729s |
> > |---------|---------|---------|---------|---------|---------|---------|
> >
> >
> >
> >
> > NFS v4.2:
> >                             Trial
> > |---------|---------|---------|---------|---------|---------|---------|
> > |         |    1    |    2    |    3    |    4    |    5    | Average |
> > |---------|---------|---------|---------|---------|---------|---------|
> > |    Data |  6.707s |  7.070s |  6.722s |  6.761s |  6.810s |  6.814s |
> > |    Hole |  5.152s |  5.149s |  5.213s |  5.206s |  5.312s |  5.206s |
> > |   Mixed |  7.979s |  7.985s |  8.177s |  7.772s |  8.280s |  8.039s |
> > |---------|---------|---------|---------|---------|---------|---------|
> >
> >
> >
> >
> >
> > #######################
> > #                     #
> > #   With READ_PLUS    #
> > #                     #
> > #######################
> >
> >
> > NFS v4.1:
> >                             Trial
> > |---------|---------|---------|---------|---------|---------|---------|
> > |         |    1    |    2    |    3    |    4    |    5    | Average |
> > |---------|---------|---------|---------|---------|---------|---------|
> > |    Data |  9.082s |  7.008s |  7.116s |  6.771s |  7.902s |  7.576s |
> > |    Hole |  5.333s |  5.358s |  5.380s |  5.161s |  5.282s |  5.303s |
> > |   Mixed |  8.189s |  8.308s |  9.540s |  7.937s |  8.420s |  8.479s |
> > |---------|---------|---------|---------|---------|---------|---------|
> >
> >
> >
> >
> > NFS v4.2:
> >                             Trial
> > |---------|---------|---------|---------|---------|---------|---------|
> > |         |    1    |    2    |    3    |    4    |    5    | Average |
> > |---------|---------|---------|---------|---------|---------|---------|
> > |    Data |  7.033s |  6.829s |  7.025s |  6.873s |  7.134s |  6.979s |
> > |    Hole |  1.794s |  1.800s |  1.905s |  1.811s |  1.725s |  1.807s |
> > |   Mixed |  7.590s |  8.777s |  9.423s | 10.366s |  8.024s |  8.836s |
> > |---------|---------|---------|---------|---------|---------|---------|
> >
> 
> So there is a clear win in the 100% hole case here, but otherwise the
> statistical fluctuations are dominating the numbers. Can you get us a
> little more stats and then perhaps run the results through nfsometer?

Also, could you describe the setup (are these still kvm's), and how
you're clearing the cache between runs?

--b.
