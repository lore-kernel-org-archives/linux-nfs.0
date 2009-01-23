From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [GIT PULL -tip] fix 33 make headers_check warnings
Date: Fri, 23 Jan 2009 14:01:07 -0800
Message-ID: <497A3E23.7040606@zytor.com>
References: <1232223441.3966.22.camel@localhost.localdomain>  <1232228261.27094.0.camel@macbook.infradead.org>  <20090117221932.GA4956@uranus.ravnborg.org>  <49725B1E.604@kernel.org>  <1232498319.3123.34.camel@localhost.localdomain>  <1232726359.3504.18.camel@localhost.localdomain> <1232726658.3504.22.camel@localhost.localdomain> <alpine.LSU.2.00.0901231710350.15413@fbirervta.pbzchgretzou.qr> <497A3793.5090502@zytor.com> <alpine.LSU.2.00.0901232252510.25716@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Jaswinder Singh Rajput <jaswinder@kernel.org>,
	"H. Peter Anvin" <hpa@kernel.org>, Sam Ravnborg <sam@ravnborg.org>,
	David Woodhouse <dwmw2@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>,
	urs.thuermann@volkswagen.de, oliver.hartkopp@volkswagen.de,
	linux-media@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org, bfields@fieldses.org, neilb@suse.de,
	linux-nfs@vger.kernel.org, linux-raid@vger.kernel.org,
	dbrownell@users.sourceforge.net, netdev@vger.kernel.org,
	greg@kroah.com, linux-usb@vger.kernel.org,
	linux-mtd@lists.infradead.org, tiwai@suse.de,
	mchehab@infradead.org, LKML <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <linux-raid-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.00.0901232252510.25716@fbirervta.pbzchgretzou.qr>
Sender: linux-raid-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Jan Engelhardt wrote:
> 
> Hm, maybe g++ defaults to std? Because this works without me using
> "using std;"
> 
> #include <cstdint>
> int main(void)
> {
> 	uint32_t x;
> }
> 

Sorry, this was a bit of a surprise... basically the g++ <cstdint> 
functionally does #include <stdint.h> then exports the symbols into the 
std namespace, so it puts them into both...

	-hpa


