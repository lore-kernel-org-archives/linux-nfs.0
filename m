Return-Path: <malahal@us.ibm.com>
Date: Thu, 4 Feb 2016 17:29:56 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: Benjamin Coddington <bcodding@redhat.com>
Cc: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] Ignore whitespace at the beginning of option tags
Message-ID: <20160204232956.GA1290@us.ibm.com>
References: <1454020727-1814-1-git-send-email-malahal@us.ibm.com>
 <56B0CA44.40105@RedHat.com>
 <alpine.OSX.2.19.9992.1602030655230.16954@planck.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <alpine.OSX.2.19.9992.1602030655230.16954@planck.local>
List-ID: <linux-nfs.vger.kernel.org>

Sorry Steve, Ben is right. It is based on
"git://git.linux-nfs.org/projects/steved/libnfsidmap.git"

Do I need to re-clone my repo with something else?

Regards, Malahal.

Benjamin Coddington [bcodding@redhat.com] wrote:
> On Tue, 2 Feb 2016, Steve Dickson wrote:
> >
> > On 01/28/2016 05:38 PM, Malahal Naineni wrote:
> > > The following should work now:
> > >
> > > [General]
> > > 	Domain = local.domain.edu
> > >
> > > Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
> > > ---
> > >  cfg.c | 9 ++++++++-
> > Ok.. I give... :-) What is this patch relative to? There is
> > a conf_parse_line() in support/nfs/conffile.c but there
> > is no cfg.c file in nfs-utils... and this patch does
> > not apply...
> 
> This is for libnfsidap..  cc-ing Bruce.
> 
> Ben
> 
> > >  1 file changed, 8 insertions(+), 1 deletion(-)
> > >
> > > diff --git a/cfg.c b/cfg.c
> > > index c615d24..e0ab839 100644
> > > --- a/cfg.c
> > > +++ b/cfg.c
> > > @@ -210,6 +210,7 @@ static void
> > >  conf_parse_line (int trans, char *line, size_t sz)
> > >  {
> > >    char *val;
> > > +  char *tag;
> > >    size_t i;
> > >    int j;
> > >    static char *section = 0;
> > > @@ -262,8 +263,14 @@ conf_parse_line (int trans, char *line, size_t sz)
> > >  	/* Skip trailing whitespace, if any */
> > >  	for (j = sz - (val - line) - 1; j > 0 && isspace (val[j]); j--)
> > >  	  val[j] = '\0';
> > > +
> > > +	/* Skip beginning white space */
> > > +	tag = line;
> > > +	while (isspace(*tag))
> > > +		tag++;
> > > +
> > >  	/* XXX Perhaps should we not ignore errors?  */
> > > -	conf_set (trans, section, line, val, 0, 0);
> > > +	conf_set (trans, section, tag, val, 0, 0);
> > >  	return;
> > >        }
> > >
> > >
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> >
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
